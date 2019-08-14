CREATE TABLE [dbo].[PRICES]
(
[STORE] [int] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [smallint] NOT NULL,
[ASTART] [datetime] NOT NULL,
[AFINISH] [datetime] NOT NULL,
[CYCLE] [datetime] NULL,
[CSTART] [datetime] NULL,
[CFINISH] [datetime] NULL,
[CSPEC] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[GDGID] [int] NOT NULL,
[GDCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NULL,
[ISGFT] [smallint] NOT NULL,
[PSETTLENO] [int] NULL,
[OCRTIME] [datetime] NOT NULL CONSTRAINT [DF__PRICES__OCRTIME__769B6138] DEFAULT (getdate()),
[PRMRATIO] [decimal] (24, 4) NULL,
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PRICES__QPC__778F8571] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRICES] ADD CONSTRAINT [PK__PRICES__6771599D] PRIMARY KEY CLUSTERED  ([STORE], [CLS], [BILLNUM], [BILLLINE], [GDGID], [GDCODE]) ON [PRIMARY]
GO