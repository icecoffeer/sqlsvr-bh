CREATE TABLE [dbo].[PS3_ONLINEPROMACTIVITY]
(
[ACTIVITY] [varchar] (60) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ACTNAME] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[START] [datetime] NOT NULL,
[FINISH] [datetime] NOT NULL,
[PRMPRC] [decimal] (24, 2) NOT NULL,
[PRMTYPE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3_ONLIN__PRMTY__7A675FDC] DEFAULT ('price'),
[PRMTEMPLATE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3_ONLIN__PRMTE__7B5B8415] DEFAULT ('single_price'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3_ONLIN__LSTUP__7C4FA84E] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ONLINEPROMACTIVITY] ADD CONSTRAINT [PK__PS3_ONLI__0A558E01787F176A] PRIMARY KEY CLUSTERED  ([ACTIVITY], [GDGID], [START], [FINISH]) ON [PRIMARY]
GO
