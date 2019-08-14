SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[TaxSortAdj_Rcv]
(
  @Src int,
  @ID int,
  @Oper Char(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
  declare
    @type int,
    @cnt int,
    @n_num char(14),
    @line int,
    @checker char(30),
    @ret int,
    @settleno int,
    @nd_line int,
    @nd_lgid int,
    @nd_oldtaxsort int,
    @nd_newtaxsort int,
    @nd_note varchar(100),
    @n_frcchk smallint,
    @nd_QPC money,
    @nd_QPCSTR varchar(15),
    @opt_AlloRcvNExt int--zz 080808

  exec OptReadInt 0, 'AlloRcvNExt', 0, @opt_AlloRcvNExt output--zz 080808
  select @type =type from NTaxSortAdj where src = @src and id = @id
  if @@rowcount <1
  begin
    set @Msg ='未找到指定税务分类调整单'
    update NTaxSortAdj set nstat = 1,nnote = @Msg where src = @src and id = @id
    return 1
  end;
  if @type<>1
  begin
    set @Msg ='不是可接收单据'
    update NTaxSortAdj set nstat = 1,nnote = @Msg where src = @src and id = @id
    return 1
  end
  if @opt_AlloRcvNExt <> 1
  begin
    select @cnt = sum(case when X.LGid is null then 1 else 0 end)
      from NTaxSortAdjDtl N, GDXLATE X
      where N.Src = @src and N.Id = @id and
      N.GdGid *= X.NGid
    if @cnt > 0
    begin
      set @Msg='本地未包含商品资料'
      update NTaxSortAdj set nstat = 1,nnote = @Msg where src = @src and id = @id
      return 1
    end
  end
  select @n_num =num,@n_frcchk = FrcChk from NTaxSortAdj where src = @src and id = @id
  if exists (select 1 from TaxSortAdj where num =@n_num)--zz 081110
  begin
    set @Msg = '该单据已被接收过,不允许重复接收';
    update NTaxSortAdj set nstat = 1,nnote = @Msg where src = @src and id = @id
    return 1
  end
  select @settleno = max(no) from monthsettle
  if @opt_AlloRcvNExt = 1
    declare c_TaxSortAdj_rcv cursor for
     select N.Line, isnull(X.LGid, N.GdGid), N.OLDTAXSORT , N.NEWTAXSORT, N.NOTE
     from NTAXSORTADJDTL N, GDXLATE X
     where N.Src = @src and N.Id = @id and N.GdGid *= X.NGid
  else
    declare c_TAXSORTAdj_rcv cursor for
     select N.Line, X.LGid, N.OLDTAXSORT , N.NEWTAXSORT, N.NOTE
     from NTAXSORTADJDTL N, GDXLATE X
     where N.Src = @src and N.Id = @id and N.GdGid = X.NGid

  open c_TaxSortAdj_rcv
  fetch next from c_TaxSortAdj_rcv into @nd_line, @nd_lgid,
    @nd_oldtaxsort, @nd_newtaxsort, @nd_note

  --2005.10.14, Added by ShenMin, Q5047, 售价调整单记录日志
  if @@fetch_status = 0
    exec WritePrcAdjLog '网络售价', @n_num, '接收'

  while @@fetch_status = 0
  begin
    insert into TaxSortAdjDtl
      (NUM, LINE, GDGID, OLDTAXSORT, NEWTAXSORT, NOTE)
      values (@n_num, @nd_line, @nd_lgid, @nd_oldtaxsort, @nd_newtaxsort, @nd_note)
    update TaxSortAdjDtl Set OLDTAXSORT = b.TAXSORT from TaxSortAdjDtl a, GOODS b
      where a.GDGID = @nd_lgid and a.GDGID = b.GID and a.NUM = @n_num and a.LINE = @nd_line   

    fetch next from c_TaxSortAdj_rcv into @nd_line, @nd_lgid,
      @nd_oldtaxsort, @nd_newtaxsort, @nd_note
  end
  close c_TaxSortAdj_rcv
  deallocate c_TaxSortAdj_rcv

  insert into TaxSortAdj (num, settleno, fildate, filler, checker, chkdate, stat, note,
    reccnt, launch, eon, src, srcnum, sndtime, prntime, lstupdtime, province)
  select @n_num, @settleno, fildate, filler, checker, chkdate, 0, note, reccnt, launch,
    1, src, num, sndtime, null, lstupdtime, province from NTaxSortAdj where src = @src and id = @id

  if @opt_AlloRcvNExt <> 1
  begin
    if not exists (select 1 from TaxSortAdjDtl(nolock) where num = @n_num)
    begin
      delete from TaxSortAdj where num = @n_num
      delete from TaxSortAdjDtl where num = @n_num
    end
  end

  update TaxSortAdj set reccnt = (select count(1) from TaxSortAdjDtl(nolock) where num = @n_num)
    where num = @n_num
  if @n_frcchk=1
  begin
    select @checker = checker from TaxSortAdj where num = @n_num
    execute @ret = TaxSortAdj_To100 @n_num, @checker, @msg output
    if @ret <>0
    begin
      return @ret
    end
  end
  delete from NTaxSortAdj where Src = @src and Id = @id
  delete from NTaxSortAdjDtl where Src = @src and Id = @id
End
GO
