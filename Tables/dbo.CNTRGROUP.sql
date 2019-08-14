CREATE TABLE [dbo].[CNTRGROUP]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [int] NOT NULL,
[VENDOR] [int] NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[REALENDDATE] [datetime] NULL,
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__CNTRGROUP__STAT__4C79738C] DEFAULT (0),
[TAG] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CNTRGROUP] ADD CONSTRAINT [PK__CNTRGROUP__4D6D97C5] PRIMARY KEY CLUSTERED  ([NUM], [VERSION]) ON [PRIMARY]
GO
