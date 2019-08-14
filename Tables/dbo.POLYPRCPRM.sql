CREATE TABLE [dbo].[POLYPRCPRM]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL,
[RECCNT] [int] NOT NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL,
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PSETTLENO] [int] NULL,
[OCRTYPE] [smallint] NOT NULL,
[OCRTIME] [datetime] NULL,
[EXGDRECCNT] [int] NOT NULL CONSTRAINT [DF__POLYPRCPR__EXGDR__30D551CA] DEFAULT (0),
[POLYPRIOR] [smallint] NOT NULL CONSTRAINT [DF__POLYPRCPR__POLYP__59033EB5] DEFAULT (0),
[PRIORITY] [int] NOT NULL CONSTRAINT [DF__POLYPRCPR__PRIOR__781CC2B2] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYPRCPRM] ADD CONSTRAINT [PK__POLYPRCPRM__31C97603] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO