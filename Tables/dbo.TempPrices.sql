CREATE TABLE [dbo].[TempPrices]
(
[STORE] [int] NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[BILLLINE] [smallint] NULL,
[ASTART] [datetime] NULL,
[AFINISH] [datetime] NULL,
[CYCLE] [datetime] NULL,
[CSTART] [datetime] NULL,
[CFINISH] [datetime] NULL,
[CSPEC] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[GDGID] [int] NULL,
[GDCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[QTY] [decimal] (24, 4) NULL,
[ISGFT] [smallint] NULL,
[OCRTIME] [datetime] NULL,
[PRMRATIO] [decimal] (24, 4) NULL,
[QPC] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
