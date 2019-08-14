CREATE TABLE [dbo].[testinserttrigger]
(
[a] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TESTINSERTTRIGGER_INS] on [dbo].[testinserttrigger] for insert as
begin
  insert into testinsertinfo(a)
  select a from inserted
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TESTINSERTTRIGGER_INS2] on [dbo].[testinserttrigger] for insert as
begin
  insert into testinsertinfo(a)
  select a from inserted
end
GO
