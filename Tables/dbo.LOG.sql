CREATE TABLE [dbo].[LOG]
(
[TIME] [datetime] NOT NULL,
[MONTHSETTLENO] [int] NULL,
[EMPLOYEECODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[EMPLOYEENAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WORKSTATIONNO] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODULENAME] [char] (128) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [smallint] NULL,
[CONTENT] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[LOG_INS] on [dbo].[LOG] for insert as
begin
  declare 
    @time datetime,
    @Code varchar(100),
    @type int,
    @count int
  declare c_ins CURSOR for
    select time, EmployeeCode, Type from inserted

  open c_ins
  fetch next from c_ins into @time, @code, @type
  while @@fetch_status = 0
  begin    
    --当每天插入第一天日结出错记录时，触发消息提醒
    if (@code = 'STARTUP') and (@type = 202)
    begin
      select @count = Count(*) from log where time >= FLOOR(Convert(Float, getDate())) and EmployeeCode = 'STARTUP' and Type = 202 and time <> @time
      if (@count = 0) exec MSCB_STARTUPFAILED_PROMPT '日结转存在错误，请查阅日志'
    end
    fetch next from c_ins into @time, @code, @type
  end
  close c_ins
  deallocate c_ins
  --结束消息提醒
end
GO
CREATE NONCLUSTERED INDEX [IX_LOG_TIME] ON [dbo].[LOG] ([TIME]) ON [PRIMARY]
GO
