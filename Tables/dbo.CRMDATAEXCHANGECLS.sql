CREATE TABLE [dbo].[CRMDATAEXCHANGECLS]
(
[FSRCORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FDESTORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FEXGSRC] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FEXGCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FACTIVE] [smallint] NOT NULL CONSTRAINT [DF__CRMDATAEX__FACTI__76C71518] DEFAULT (0),
[FSQLITEM1] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM2] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM3] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM4] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM5] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM6] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM7] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM8] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM9] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM10] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM11] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM12] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM13] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM14] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FSQLITEM15] [text] COLLATE Chinese_PRC_CI_AS NULL,
[FNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMDATAEXCHANGECLS] ADD CONSTRAINT [PK__CRMDATAEXCHANGEC__77BB3951] PRIMARY KEY CLUSTERED  ([FSRCORG], [FDESTORG], [FEXGCLS]) ON [PRIMARY]
GO