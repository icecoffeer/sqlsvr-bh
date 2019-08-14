SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[StartUp_Step_PolyPrcPrm]  
as  
begin  
  declare  
    @return_status smallint,  
    @Num char(14),  
    @Msg varchar(255),  
    @SettleNo int,  
    @Present datetime  
  set @Present = GetDate()  
  select @SettleNo = max(no) from MONTHSETTLE(nolock)  
  
  --生效
  insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
    values(@Present, @SettleNo, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 101, '批量价格促销单日结生效。' )  
  declare c_PolyPrcPrm cursor for  
    select NUM from PolyPrcPrm(nolock)  
    where STAT = 100  
      and OCRTYPE = 1  
      and OCRTIME <= @Present  
    order by NUM  
  open c_PolyPrcPrm  
  fetch next from c_PolyPrcPrm into @Num  
  while @@fetch_status = 0  
  begin  
    begin transaction  
    exec @return_status = PolyPrcPrm_On_Modify @Num, 800, '日结生效', @Msg output  
    if @return_status <> 0  
    begin  
      rollback transaction  
      begin transaction  
      set @Msg = substring('批量价格促销单 ' + @Num + ' 日结生效失败。'  
        + char(10) + @Msg, 1, 255)  
      waitfor delay '0:00:0.010'  
      insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
        values(@Present, @SettleNo, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 304, @Msg);  
      commit transaction  
    end else  
      commit transaction  
    fetch next from c_PolyPrcPrm into @Num  
  end  
  close c_PolyPrcPrm  
  deallocate c_PolyPrcPrm  
  
  --终止
  insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values(@Present, @SettleNo, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 101, '批量价格促销单日结终止。' )
  declare c_end cursor for
      select MST.NUM from PolyPrcPrm MST,PolyPrcPrmdtldtl DTL
      where MST.STAT = 800  AND DTL.NUM = MST.NUM
      GROUP BY MST.NUM
      HAVING MAX(DTL.FINISH) < @Present        
  open c_end
  fetch next from c_end into @Num
  while @@fetch_status = 0
  begin
    begin transaction
    exec @return_status = PolyPrcPrm_On_Modify @Num, 1400, '日结终止', @Msg output
    if @return_status <> 0
    begin
      rollback transaction
      begin transaction
      set @Msg = substring('批量价格促销单 ' + @Num + ' 日结终止失败。'
        + char(10) + @Msg, 1, 255)
      waitfor delay '0:00:0.010'
      insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
        values(@Present, @SettleNo, 'STARTUP', 'HDSVC', 'SETTLEDAY', 'STARTUP', 304, @Msg);
      commit transaction
    end else
      commit transaction
    fetch next from c_end into @Num
  end
  close c_end
  deallocate c_end    
  
  return 0  
end  
GO
