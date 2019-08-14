CREATE TABLE [dbo].[dbcctemp]
(
[no] [smallint] NOT NULL,
[tablename] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[tag] [int] NOT NULL CONSTRAINT [DF__dbcctemp__tag__367DAEC7] DEFAULT (0)
) ON [PRIMARY]
GO
