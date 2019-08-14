SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_ON_RECEIVE]
(
  @piSrc int,
  @piId int,
  @piOper varChar(30),
  @poErrMsg VARCHAR(255) OUTPUT
)
As
Begin
  declare @type int,
          @cnt int,
          @n_num char(14),
          @line int,
          @checker char(30),
          @ret int,
          @settleno int,
          @nd_line int,
          @nd_lgid int,
          @nd_note varchar(100),
          @n_frcchk smallint,
          @nd_lowlimit money, 
          @nd_toplimit money,
          @nd_limitper money,
          @nd_limittotal money

  select @type = NTYPE from NPS3REDBLUECARD(nolock) where src = @piSrc and ID = @piID
  if @@rowcount < 1
  begin
    set @poErrMsg ='未找到指定红蓝限制单'
    update NPS3REDBLUECARD set nstat = 1,nnote = @poErrMsg where src = @piSrc and ID = @piID
    return 1
  end;
  if @type <> 1
  begin
    set @poErrMsg = '不是可接收单据'
    update NPS3REDBLUECARD set nstat = 1,nnote = @poErrMsg where src = @piSrc and ID = @piID
    return 1
  end
  select @cnt = sum(case when X.LGid is null then 1 else 0 end)
    from NPS3REDBLUECARDDTL N(nolock), GDXLATE X(nolock)
     where N.Src = @piSrc and N.ID = @piID and N.GdGid *= X.NGid
  if @cnt > 0
  begin
    set @poErrMsg = '本地未包含商品资料'
    update NPS3REDBLUECARD set nstat = 1, nnote = @poErrMsg where src = @piSrc and ID = @piID
    return 1
  end
  select @n_num = num, @n_frcchk = FrcChk from NPS3REDBLUECARD(nolock) where src = @piSrc and ID = @piID
  if exists (select * from PS3REDBLUECARD where num = @n_num)
  begin
    set @poErrMsg = '该单据已被接收过,不允许重复接收';
    update NPS3REDBLUECARD set nstat = 1, nnote = @poErrMsg where src = @piSrc and ID = @piID
    return 1
  end
  select @settleno = max(no) from monthsettle
  declare c_RedBlueRcv cursor for
    select N.Line, X.LGid, N.LOWLIMIT, N.TOPLIMIT, N.LIMITPERCENT, N.LIMITTOTAL, N.NOTE from NPS3REDBLUECARDDTL N, GDXLATE X
      where N.Src = @piSrc and N.ID = @piID and N.GdGid *= X.NGid
  open c_RedBlueRcv
  fetch next from c_RedBlueRcv into @nd_line, @nd_lgid, @nd_lowlimit, @nd_toplimit, @nd_limitper, @nd_limitTotal, @nd_note

  --写入日志
  if @@fetch_status = 0
    insert into NPS3REDBLUECARDLOG(NUM, MODIFIER, TIME, ACT)
      VALUES (@n_num, @piOper, GETDATE(), '接收')

  while @@fetch_status = 0
  begin
    insert into PS3REDBLUECARDDTL
      (NUM, LINE, GDGID, LOWLIMIT, TOPLIMIT, LIMITPERCENT, LIMITTOTAL, NOTE)
      values (@n_num, @nd_line,@nd_lgid, @nd_lowlimit, @nd_toplimit, @nd_limitper, @nd_limittotal, @nd_note)
   fetch next from c_RedBlueRcv into @nd_line, @nd_lgid, @nd_lowlimit, @nd_toplimit, @nd_limitper, @nd_limitTotal, @nd_note
  end
  close c_RedBlueRcv 
  deallocate c_RedBlueRcv 

  insert into PS3REDBLUECARD(num, settleno, stat, vendor, filler, fildate, checker, chkdate, note, src)
    select @n_num, @settleno, 0, vendor, filler, fildate, checker, chkdate, note, @piSrc
  from NPS3REDBLUECARD where src = @piSrc and ID = @piID

  if @n_frcchk = 1
  begin
    select @checker=checker from NPS3REDBLUECARD(nolock) where num=@n_num
    execute @ret= PS3_REDBLUELIMIT_STAT_TO_100 @n_num, @checker,@poErrMsg output
    if @ret <>0
    begin
      return @ret
    end
  end

  delete from NPS3REDBLUECARD where Src = @piSrc and ID = @piID
  delete from NPS3REDBLUECARDDtl where Src = @piSrc and ID = @piID
  return 0
End
GO
