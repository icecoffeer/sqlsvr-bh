SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  Procedure [dbo].[PayRatePrmRcv]
(
  @Src int,
  @ID int,
  @Oper varChar(30),
  @MSG VARCHAR(255) OUTPUT
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
          @nd_payrate money,
          @nd_note varchar(100),
          @n_frcchk smallint,
          @nd_QPC money,
          @nd_QPCSTR varchar(15),
          @AStart datetime,
          @AFinish datetime

  select @type =type from NPayRatePrm where src=@src and id=@id
  if @@rowcount <1
  begin
    set @Msg ='未找到指定联销率促销单'
    update NPayRatePrm set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end;
  if @type<>1
  begin
    set @Msg ='不是可接收单据'
    update NPayRatePrm set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @cnt = sum(case when X.LGid is null then 1 else 0 end)
    from NPayRatePrmDtl N, GDXLATE X
    where N.Src = @src and N.Id = @id and
    N.GdGid *= X.NGid
  if @cnt > 0
  begin
    set @Msg='本地未包含商品资料'
    update NPayRatePrm set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @n_num =num,@n_frcchk = FrcChk from NPayRatePrm where src=@src and id=@id
  if exists (select * from PayRatePrm where num =@n_num)
  begin
    set @Msg='该单据已被接收过,不允许重复接收';
    update NPayRatePrm set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @settleno = max(no) from monthsettle
  declare c_PayRatePrm_rcv cursor for
   select N.Line, X.LGid,N.PAYRATE, N.QPC, N.QPCSTR, N.ASTART, N.AFINISH from NPayRatePrmDtl N, GDXLATE X
   where N.Src = @src and N.Id = @id and N.GdGid *= X.NGid
  open c_PayRatePrm_rcv
  fetch next from c_PayRatePrm_rcv into @nd_line, @nd_lgid, @nd_payrate, @nd_QPC, @nd_QPCSTR, @AStart, @AFinish

  if @@fetch_status = 0
    INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
    VALUES (@n_num, @OPER, GETDATE(), '接收')

  while @@fetch_status = 0
  begin
    insert into PayRatePrmDtl
      (num, line, gdgid, PayRate, QPC, QPCSTR, ASTART, AFINISH, SETTLENO)
      values (@n_num,@nd_line,@nd_lgid,@nd_PayRate, @nd_QPC, @nd_QPCSTR, @AStart, @AFinish, @settleno)
   fetch next from c_PayRatePrm_rcv into @nd_line, @nd_lgid, @nd_payrate, @nd_QPC, @nd_QPCSTR, @AStart, @AFinish
  end
  close c_PayRatePrm_rcv
  deallocate c_PayRatePrm_rcv

  insert into PayRatePrm (num,settleno,fildate,filler,checker,chkdate,stat,note,
    reccnt,launch,eon,src,sndtime,prntime,LASTMODIFIER,lstupdtime)
    select @n_num,@settleno,fildate,filler,checker,chkdate,0,note,reccnt,launch,
    1,src,sndtime,null,LASTMODIFIER,lstupdtime from NPayRatePrm where src=@src and id=@id

  if @n_frcchk=1
  begin
    select @checker=checker from PayRatePrm where num=@n_num
    execute @ret= PayRatePrmChk @n_num,@checker,@msg output
    if @ret <>0
    begin
      return @ret
    end
  end
  delete from NPayRatePrm where Src = @src and Id = @id
  delete from NPayRatePrmDtl where Src = @src and Id = @id
End
GO
