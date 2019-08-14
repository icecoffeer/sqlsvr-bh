SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_PrmOffset]
--with encryption
as
begin
  declare
   	@Num varchar(14),	@ret int, @poErrmsg varchar(255)

  set @ret = 0
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '促销补差单' );

	declare C cursor for select Num from prmoffset where Launch <= getdate()
	open C
	fetch next from C into @Num
	while @@fetch_status = 0
	begin
	  exec @ret = PRMOFFSETOCR @Num, 'STARTUP', 0, null, @poErrmsg output
	  if @ret <> 0
	  begin
	    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
	    values (getdate(), 'STARTUP', 'HDSVC', 'PRMOFFSETOCR', 202, @poErrmsg )
	  end
	   fetch next from C into @Num
	end
	close C
	deallocate C
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_PrmOffset', 0, ''  --合并日结
  return(0)
end

GO
