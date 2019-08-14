SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_GdSaleAdj]
--with encryption
as
begin
  declare
    @gdsaleadj_num char(14),
    @gdsaleadj_settleno int,
    @gdsaleadj_fildate datetime,
    @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '自动生效调整营销方式' )

  declare c_gdsaleadj2 cursor for
    select NUM, SETTLENO, fildate from gdsaleadj where STAT = 100 and LAUNCH <= GETDATE()
    order by fildate
  open c_gdsaleadj2
  fetch next from c_gdsaleadj2 into @gdsaleadj_num,
    @gdsaleadj_settleno, @gdsaleadj_fildate
  while @@fetch_status = 0
  begin
    execute @return_status = CHKGdSaleAdj_TO800 @gdsaleadj_num, '未知[-]', '', 800, ''
    if @return_status <> 0
    begin
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'chkgdsaleadj_To800', 202, @gdsaleadj_num )
    end
    fetch next from c_gdsaleadj2 into @gdsaleadj_num, @gdsaleadj_settleno, @gdsaleadj_fildate
  end
  close c_gdsaleadj2
  deallocate c_gdsaleadj2
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_GdSaleAdj', 0, ''   --合并日结
  return(0)
end

GO
