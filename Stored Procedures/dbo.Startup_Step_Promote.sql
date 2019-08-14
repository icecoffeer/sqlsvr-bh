SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_Promote]  
--with encryption  
as  
begin  
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '促销标志' )  
  update GOODS set PROMOTE = -1  
  where PROMOTE <> -1 and not exists (  
    select * from PRICE where GDGID = GOODS.GID and FINISH >= GETDATE()  
    and STOREGID = (SELECT USERGID FROM SYSTEM(NOLOCK))         --2003.08.22  
  )  
  
  /* 各店商品促销标志 2003.08.22*/  
  waitfor delay '0:0:0.010'  
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)  
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '各店商品促销标志' )  
  update GDSTORE set PROMOTE = -1 where PROMOTE <> -1 and not exists (  
    select * from PRICE where GDGID = GDSTORE.GDGID and FINISH >= GETDATE()  
    and STOREGID = GDSTORE.STOREGID  
  )  
    
  --sunya  
  /*--联销商品促销标志 ShenMin, 2006.6.16  
  waitfor delay '0:0:0.010'  
  update GOODS set PROMOTE = -1  
  where PROMOTE <> -1 and SALE = 3 and not exists (  
  select * from PAYRATEPRICE where GDGID = GOODS.GID and AFINISH >= GETDATE()  
  and STOREGID = (SELECT USERGID FROM SYSTEM(NOLOCK))  
  )  
  
  --联销各店商品促销标志 ShenMin, 2006.6.16  
  waitfor delay '0:0:0.010'  
  update GDSTORE set PROMOTE = -1 where PROMOTE <> -1 and SALE = 3 and not exists (  
    select * from PAYRATEPRICE where GDGID = GDSTORE.GDGID and AFINISH >= GETDATE()  
    and STOREGID = GDSTORE.STOREGID  
  ) */  
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_Promote', 0, ''  --合并日结  
  return(0)  
end  

GO
