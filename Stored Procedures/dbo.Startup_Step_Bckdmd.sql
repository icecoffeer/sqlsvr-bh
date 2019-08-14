SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_Bckdmd]
--with encryption
as
begin
  declare
    @bckdmd_num char(14),      @bckdmd_stat int,
    @bckdmd_src int,           @bckdmd_chkstoregid int,
    @bckdmd_snddate datetime,  @bckdmd_dmdstore int,
    @userproperty int,
    @usergid int,                 @ret_stat int,
    @poMsg varchar(255)

  select @usergid = USERGID, @userproperty = userproperty from SYSTEM
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '终止配货退货申请单' )
  declare c_bckdmd cursor for
    select NUM, STAT, SRC, CHKSTOREGID, SNDDATE, DMDSTORE from BCKDMD
      where STAT in (401, 1600, 400) and EXPDATE < getdate()
        and ((LOCKNUM is null) or (rtrim(LOCKNUM)=''))
      order by EXPDATE
  open c_bckdmd
  fetch next from c_bckdmd into @bckdmd_num, @bckdmd_stat, @bckdmd_src,
    @bckdmd_chkstoregid, @bckdmd_snddate, @bckdmd_dmdstore
  while @@fetch_status = 0
  begin
    /*if not (@userproperty & 16 = 16 and @bckdmd_snddate is null)
      if @bckdmd_dmdstore <> @usergid
      begin
        fetch next from c_bckdmd into @bckdmd_num, @bckdmd_stat, @bckdmd_src,
          @bckdmd_chkstoregid, @bckdmd_snddate, @bckdmd_dmdstore
        continue
      end*/
    begin tran
  --  if @bckdmd_stat = 401
      execute @ret_stat = BckDmdChk @bckdmd_num, '日结', '', 1400, @poMsg output
   -- else if @bckdmd_stat = 400
    --  execute @ret_stat = BckDmdChk @bckdmd_num, '日结', '', 410, @poMsg output

   /* if ((@bckdmd_src = @usergid) and (@bckdmd_snddate is not null)) or
       (@bckdmd_src <> @usergid) and (@ret_stat = 0)
    begin
      execute @ret_stat = sendbckdmd @bckdmd_num, '日结', '', 0, @poMsg output
    end*/
    if @ret_stat <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT) values (getdate(), 'STARTUP', 'HDSVC',
      'BckDmdChk', 202, @bckdmd_num + ' - ' +@poMsg )
    end
    else
    begin
      commit tran
      waitfor delay '0:0:0.001'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT) values (getdate(), 'STARTUP', 'HDSVC',
      'BckDmdChk', 304, @bckdmd_num + ' - 终止成功' )
    end
    fetch next from c_bckdmd into @bckdmd_num, @bckdmd_stat, @bckdmd_src,
      @bckdmd_chkstoregid, @bckdmd_snddate, @bckdmd_dmdstore
  end
  close c_bckdmd
  deallocate c_bckdmd
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_Bckdmd', 0, ''  --合并日结
  return(0)
end

GO
