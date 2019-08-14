SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_ProcTask]
--with encryption
as
begin
  declare
   	@Num varchar(14),	@ret int, @poErrmsg varchar(255)

  set @ret = 0
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'STARTUP', 'HDSVC', 'SETTLEDAY', 101, '加工任务单' );

	declare C cursor for select Num from proctask where endtime <= getdate() and Stat = 100 --Edited by Zhuhaohui, 12323 加工任务单日结过程BUG
	open C
	fetch next from C into @Num
	while @@fetch_status = 0
	begin
	  exec @ret = PROCTASK_CHKTO300 @Num, 'STARTUP', '', null, @poErrmsg output
	  if @ret <> 0
	  begin
	    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
	    values (getdate(), 'STARTUP', 'HDSVC', 'PROCTASK_CHKTO300', 202, @poErrmsg )
	  end
	   fetch next from C into @Num
	end
	close C
	deallocate C
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_ProcTask', 0, ''   --合并日结
  return(0)
end

GO
