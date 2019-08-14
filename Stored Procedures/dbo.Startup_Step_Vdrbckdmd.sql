SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_Vdrbckdmd]
--with encryption
as
begin
  declare
    @vdrbckdmd_num char(14),      @vdrbckdmd_stat int,
    @vdrbckdmd_src int,           @vdrbckdmd_chkstoregid int,
    @vdrbckdmd_snddate datetime,  @vdrbckdmd_dmdstore int,
    @return_status int,           @userproperty int,
    @usergid int,                 @ret_stat int,
    @poMsg varchar(255),          @opt_locknumcheck smallint

  exec OPTREADINT 569, '自动过期锁定单据检查', 0, @opt_locknumcheck output  --0:检查 1:不检查
  select @usergid = USERGID, @userproperty = userproperty from SYSTEM
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '终止供应商退货申请单' )
  if @opt_locknumcheck = 0
    declare c_vdrbckdmd cursor for
    select NUM, STAT, SRC, CHKSTOREGID, SNDDATE, DMDSTORE from VDRBCKDMD
      where STAT IN (401, 1600, 500) and EXPDATE < GETDATE()
        and ((locknum is null) or (rtrim(locknum)=''))
    order by EXPDATE
  else
    declare c_vdrbckdmd cursor for
    select NUM, STAT, SRC, CHKSTOREGID, SNDDATE, DMDSTORE from VDRBCKDMD
      where STAT IN (401, 1600, 500) and EXPDATE < GETDATE()
    order by EXPDATE
  open c_vdrbckdmd
  fetch next from c_vdrbckdmd into @vdrbckdmd_num, @vdrbckdmd_stat, @vdrbckdmd_src,
    @vdrbckdmd_chkstoregid, @vdrbckdmd_snddate, @vdrbckdmd_dmdstore
  while @@fetch_status = 0
  begin
   /* if not (@userproperty & 16 = 16 and @vdrbckdmd_snddate is null)
      if @vdrbckdmd_dmdstore <> @usergid
      begin
        fetch next from c_vdrbckdmd into @vdrbckdmd_num, @vdrbckdmd_stat, @vdrbckdmd_src,
          @vdrbckdmd_chkstoregid, @vdrbckdmd_snddate, @vdrbckdmd_dmdstore
        continue
      end*/
    begin tran
   -- if @vdrbckdmd_stat = 401
      execute @ret_stat = VdrBckDmdChk @vdrbckdmd_num, '日结', '', 1400, @poMsg output
  --  else if @vdrbckdmd_stat = 500
   --   execute @ret_stat = VdrBckDmdChk @vdrbckdmd_num, '日结', '', 410, @poMsg output
  /*  if ((@vdrbckdmd_src = @usergid) and (@vdrbckdmd_snddate is not null)) or
       (@vdrbckdmd_src <> @usergid) and (@ret_stat = 0)
    begin
      execute @ret_stat = VdrBckDmdSnd @vdrbckdmd_num, '日结', '', 0, @poMsg output
    end*/
    if @ret_stat <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT) values (getdate(), 'STARTUP', 'HDSVC',
      'VdrBckDmdChk', 202, @vdrbckdmd_num + ' - ' +@poMsg )
    end
    else
    begin
      commit tran
      waitfor delay '0:0:0.001'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT) values (getdate(), 'STARTUP', 'HDSVC',
      'VdrBckDmdChk', 304, @vdrbckdmd_num + ' - 终止成功' )
    end
    fetch next from c_vdrbckdmd into @vdrbckdmd_num, @vdrbckdmd_stat, @vdrbckdmd_src,
      @vdrbckdmd_chkstoregid, @vdrbckdmd_snddate, @vdrbckdmd_dmdstore
  end
  close c_vdrbckdmd
  deallocate c_vdrbckdmd
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_Vdrbckdmd', 0, ''   --合并日结
  return(0)
end

GO
