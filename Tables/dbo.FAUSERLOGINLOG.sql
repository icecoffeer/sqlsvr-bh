CREATE TABLE [dbo].[FAUSERLOGINLOG]
(
[USERGID] [int] NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__FAUSERLOG__LSTUP__03C51636] DEFAULT (getdate()),
[LASTMODIFYOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTLOGINTIME] [datetime] NULL,
[ERRTIMES] [smallint] NOT NULL CONSTRAINT [DF__FAUSERLOG__ERRTI__04B93A6F] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAUSERLOGINLOG] ADD CONSTRAINT [PK__FAUSERLOGINLOG__05AD5EA8] PRIMARY KEY CLUSTERED  ([USERGID]) ON [PRIMARY]
GO