SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdj_Snd]
(
  @NUM CHAR(14),
  @FRCCHK SMALLINT,
  @MSG VARCHAR(255) OUTPUT
)
With Encryption
As
Begin
  declare
    @user_gid int,
    @src int,
    @storegid int,
    @billid int,
    @settleno int,
    @fildate datetime,
    @filler char(30),
    @checker char(30),
    @chkdate datetime,
    @stat int,
    @note varchar(100),
    @reccnt int,
    @launch datetime,
    @sndtime datetime,
    @lstupdtime datetime

    select @user_gid = UserGid from System
    select @src = Src, @stat = Stat,@settleno=settleno,@fildate =fildate,
    @filler=filler,@checker =checker,@chkdate=chkdate,@note=note,@reccnt=reccnt,
    @launch=launch,@sndtime=getdate(),@lstupdtime=lstupdtime
      from rtlprcadj where Num = @Num

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
    if object_id('c_rtlprcadjsnd') is not null deallocate c_rtlprcadjsnd
    declare c_rtlprcadjsnd cursor for
    select storegid from rtlprcadjlacdtl where num=@num
    open c_rtlprcadjsnd
    fetch next from c_rtlprcadjsnd into @storegid

    --2005.10.14, Added by ShenMin, Q5047, 售价调整单记录日志
    if @@fetch_status = 0
        exec WritePrcAdjLog '售价', @num, '发送'

    while @@fetch_status = 0
    begin
      execute GetNetBillId @billid output
      insert into nrtlprcadj (src,id,num,settleno,fildate,filler,checker,chkdate,
        reccnt,stat,note,nstat,nnote,rcv,launch,sndtime,rcvtime,type,lstupdtime,frcchk)
      values
      (@user_gid,@billid,@num,@settleno,@fildate,@filler,@checker,@chkdate,
       @reccnt,@stat,@note,0,null,@storegid,@launch,@sndtime,null,0,@lstupdtime,@frcchk)

      insert into nrtlprcadjdtl (src,id,line,gdgid,oldrtlprc,newrtlprc,
        oldlwtprc,newlwtprc,oldtopprc,newtopprc,oldmbrprc,newmbrprc,oldwhsprc,newwhsprc,
        qty,note, QPC, QPCSTR)
        select @user_gid,@billid,line,gdgid,oldrtlprc,newrtlprc,oldlwtprc,
        newlwtprc,oldtopprc,newtopprc,oldmbrprc,newmbrprc,oldwhsprc,newwhsprc,
        qty,note, QPC, QPCSTR from rtlprcadjdtl where num=@num
      fetch next from c_rtlprcadjsnd into @storegid
    end
    close c_rtlprcadjsnd
    deallocate c_rtlprcadjsnd

    update rtlprcadj set SndTime=getdate() where num=@num
  return 0
End
GO
