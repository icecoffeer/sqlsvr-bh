SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_GoodsApp]
--with encryption
as
begin
  declare
    @goodsapp_num varchar(14),
    @ret_stat int,
    @poMsg varchar(255)
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '终止商品资料申请单' )
  declare c_goodsapp cursor for
    select NUM from GoodsApp
      where STAT = 401 and DEADDATE < GETDATE()
        and SRC = (SELECT USERGID FROM SYSTEM(NOLOCK))
      order by DEADDATE
  open c_goodsapp
  fetch next from c_goodsapp into @goodsapp_num
  while @@fetch_status = 0
  begin
    begin tran
    execute @ret_stat = GoodsAppChk @goodsapp_num, '日结', '', 411, @poMsg output
    if @ret_stat <> 0
    begin
      rollback
      waitfor delay '0:0:0.010'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT) values (getdate(), 'STARTUP', 'HDSVC',
      'GoodsAppChk', 202, @goodsapp_num + ' - ' +@poMsg )
    end
    else
    begin
      commit tran
      waitfor delay '0:0:0.001'
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT) values (getdate(), 'STARTUP', 'HDSVC',
      'GoodsAppChk', 304, @goodsapp_num + ' - 作废成功' )
    end
    fetch next from c_goodsapp into @goodsapp_num
  end
  close c_goodsapp
  deallocate c_goodsapp
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_GoodsApp', 0, ''   --合并日结
  return(0)
end

GO
