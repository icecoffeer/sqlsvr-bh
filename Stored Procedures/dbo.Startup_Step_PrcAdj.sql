SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PrcAdj]
--with Encryption
as
begin
  declare
    @prcadj_cls char(10), @prcadj_num char(10),
    @prcadj_settleno int, @prcadj_fildate datetime,
    @errmsg varchar(255),
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '自动调价' )

  declare c_prcadj cursor for
    select CLS, NUM, SETTLENO, FILDATE from PRCADJ where STAT = 1 and LAUNCH <= GETDATE()  -- and EON = 1  2001-5-9
    order by FILDATE  --for update
  open c_prcadj
  fetch next from c_prcadj into @prcadj_cls, @prcadj_num,
    @prcadj_settleno, @prcadj_fildate
  while @@fetch_status = 0
  begin
    begin tran
    execute @return_status = PRCADJGO @prcadj_cls, @prcadj_num, @errmsg output
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'PRCAJDGO', 202, @prcadj_cls + @prcadj_num + ' - ' +@errMsg )
    end
    else
      commit tran
    fetch next from c_prcadj into @prcadj_cls, @prcadj_num,
      @prcadj_settleno, @prcadj_fildate
  end
  close c_prcadj
  deallocate c_prcadj
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_PrcAdj', 0, ''  --合并日结
  return(0)
end

GO
