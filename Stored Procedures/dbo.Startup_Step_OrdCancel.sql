SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[Startup_Step_OrdCancel]
--with Encryption
as
begin
  declare @ord_num char(10)
  declare startup_ord cursor for
    select num from ord where expdate < getdate() and
    STAT = 1 and FINISHED = 0             --2002-08-16 Jianweicheng  删除SRC = (select USERGID from system)
  open startup_ord
  fetch next from startup_ord into @ord_num
  while @@fetch_status = 0
  begin
    execute abolishord @ord_num
    fetch next from startup_ord into @ord_num
  end
  close startup_ord
  deallocate startup_ord
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_OrdCancel', 0, ''   --合并日结
  return(0)
end

GO
