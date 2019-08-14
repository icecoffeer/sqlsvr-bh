SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[StartUp_Step_PolyPrm]
as
begin
  declare
    @return_status smallint,
    @Num char(14),
    @Msg varchar(255),
    @SettleNo int,
    @Present datetime,
    @Cls char(10)
  set @Present = GetDate()
  select @SettleNo = max(no) from MONTHSETTLE(nolock)
  
  --终止
  insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values(@Present, @SettleNo, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 101, '批量总额(量)促销单日结终止。' )
  declare c_end cursor for
      select MST.NUM,MST.CLS from PolyProm MST,POLYPROMRANGEDTL DTL
      where MST.STAT = 800  AND DTL.NUM = MST.NUM AND DTL.CLS = MST.CLS
      GROUP BY MST.NUM,MST.CLS
      HAVING MAX(DTL.AFINISH) < Getdate()        
  open c_end
  fetch next from c_end into @Num, @Cls
  while @@fetch_status = 0
  begin
    begin transaction
    exec @return_status = PolyProm_On_Modify @Num, @Cls, 1400, '日结终止', @Msg output
    if @return_status <> 0
    begin
      rollback transaction
      begin transaction
      set @Msg = substring('批量总额(量)促销单 ' + @Num + ' 日结终止失败。'
        + char(10) + @Msg, 1, 255)
      waitfor delay '0:00:0.010'
      insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
        values(@Present, @SettleNo, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 304, @Msg);
      commit transaction
    end else
      commit transaction
    fetch next from c_end into @Num, @Cls
  end
  close c_end
  deallocate c_end  
  
  return 0
end
GO
