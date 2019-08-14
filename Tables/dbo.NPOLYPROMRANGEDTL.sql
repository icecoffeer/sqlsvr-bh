CREATE TABLE [dbo].[NPOLYPROMRANGEDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NULL,
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ASTART] [datetime] NOT NULL CONSTRAINT [DF__NPOLYPROM__ASTAR__1C2F3A9F] DEFAULT ('1899.12.30 00:00:00'),
[AFINISH] [datetime] NOT NULL CONSTRAINT [DF__NPOLYPROM__AFINI__1D235ED8] DEFAULT ('9999.12.31 23:59:59'),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PREC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPOLYPROMR__PREC__61A5D3B3] DEFAULT (1.0),
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NPOLYPROM__ROUND__6299F7EC] DEFAULT ('四舍五入')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPOLYPROMRANGEDTL] ADD CONSTRAINT [PK__NPOLYPROMRANGEDT__1E178311] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
