CREATE TABLE [dbo].[BUYIVCCONTROL]
(
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[EIVCSTAT] [smallint] NOT NULL CONSTRAINT [DF__BUYIVCCON__EIVCS__142731DF] DEFAULT ((0)),
[LOCALSTAT] [smallint] NOT NULL CONSTRAINT [DF__BUYIVCCON__LOCAL__151B5618] DEFAULT ((0)),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__BUYIVCCON__LSTUP__160F7A51] DEFAULT (getdate())
) ON [PRIMARY]
GO
