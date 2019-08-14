SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_TaxSortAdj]
with Encryption
as
begin
  declare
    @msg varchar(255), @return_status int

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '税务分类调整单生效' )
  declare
    @taxsortadj_num char(14),
    @taxsortadj_settleno int, @taxsortadj_fildate datetime
  declare c_taxsortadj cursor for
    select NUM, SETTLENO, fildate
    from taxsortadj
    where STAT = 100 and LAUNCH <= GETDATE()
    order by fildate
  open c_taxsortadj
  fetch next from c_taxsortadj into @taxsortadj_num,
    @taxsortadj_settleno, @taxsortadj_fildate
  while @@fetch_status = 0 begin
    begin transaction
    execute @return_status = TaxSortAdj_To800 @taxsortadj_num, '日结', @msg output
    if @return_status = 0
      commit transaction
    if @return_status <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'STARTUP', 'HDSVC', 'TaxSortAdj_To800', 202, @taxsortadj_num + ' - ' + @msg)
    end
    fetch next from c_taxsortadj into @taxsortadj_num,
    @taxsortadj_settleno, @taxsortadj_fildate
  end
  close c_taxsortadj
  deallocate c_taxsortadj
  return(0)
end
GO
