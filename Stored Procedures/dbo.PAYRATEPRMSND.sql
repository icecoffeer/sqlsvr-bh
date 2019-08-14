SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PAYRATEPRMSND]
(
  @NUM CHAR(14),
  @FRCCHK SMALLINT,
  @OPER VARCHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
  declare
    @user_gid int,
    @src int,
    @storegid int,
    @billid int,
    @fildate datetime,
    @filler char(30),
    @checker char(30),
    @chkdate datetime,
    @stat int,
    @note varchar(100),
    @reccnt int,
    @launch datetime,
    @sndtime datetime,
    @lstupdtime datetime,
    @lastmodifier char(30)

    select @user_gid = UserGid from System
    select @src = Src, @stat = Stat,@fildate =fildate,
    @filler=filler,@checker =checker,@chkdate=chkdate,@note=note,@reccnt=reccnt,
    @launch=launch,@sndtime=getdate(),@lstupdtime=lstupdtime, @lastmodifier = lastmodifier
      from PayRatePrm where Num = @Num

    if @stat <> 100 and @stat <> 800
    begin
      set @Msg='不是已审核或已生效的单据'
      return 1
    end
    if @src <> @user_gid and @src <> 1
    begin
      set @Msg='不是本单位产生的单据不能发送'
      return 1
    end

    delete NPayRatePrmDtl from NPayRatePrm
    where NPayRatePrmDtl.ID = NPayRatePrm.ID and NPayRatePrm.num = @num
    delete NPayRatePrm where num = @num

    if object_id('c_PayRatePrmSnd') is not null deallocate c_PayRatePrmSnd
    declare c_PayRatePrmSnd cursor for
    select storegid from PAYRATEPRMLACDTL where num=@num
    open c_PayRatePrmSnd
    fetch next from c_PayRatePrmSnd into @storegid

   -- 记录日志
    if @@fetch_status = 0
      INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
      VALUES (@NUM, @OPER, GETDATE(), '发送')

    while @@fetch_status = 0
    begin
      execute GetNetBillId @billid output
      insert into nPayRatePrm (src,id,num,fildate,filler,checker,chkdate,
        reccnt,stat,note,nstat,nnote,rcv,launch,sndtime,rcvtime,type,lstupdtime,lastmodifier,frcchk)
      values
      (@user_gid,@billid,@num,@fildate,@filler,@checker,@chkdate,
       @reccnt,@stat,@note,0,null,@storegid,@launch,@sndtime,null,0,@lstupdtime,@lastmodifier,@frcchk)

      insert into nPayRatePrmdtl (src,id,line,gdgid,qpc,qpcstr,astart,afinish,payrate)
        select @user_gid,@billid,line,gdgid,qpc,qpcstr,astart,afinish,payrate
        from PayRatePrmdtl where num=@num
      fetch next from c_PayRatePrmSnd into @storegid
    end
    close c_PayRatePrmSnd
    deallocate c_PayRatePrmSnd

    update PayRatePrm set SndTime=getdate() where num=@num

  return 0
End
GO
