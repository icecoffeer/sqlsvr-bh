CREATE TABLE [dbo].[SDRPTS]
(
[OCRDATE] [datetime] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[BNUM] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SALE] [smallint] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[AMT] [decimal] (24, 2) NOT NULL,
[TAX] [decimal] (24, 2) NOT NULL,
[IAMT] [decimal] (24, 2) NOT NULL,
[ITAX] [decimal] (24, 2) NOT NULL,
[RTOTAL] [decimal] (24, 2) NOT NULL,
[BILLTO] [int] NOT NULL,
[VDRGID] [int] NOT NULL,
[SND] [int] NULL,
[SWRH] [int] NULL,
[RCV] [int] NULL,
[RWRH] [int] NULL,
[VALIDDATE] [datetime] NULL,
[VBNUM] [char] (16) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SDRPT_FILDATE] ON [dbo].[SDRPTS] ([FILDATE], [CLS], [GDGID], [SND]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SDRPT_GDGID] ON [dbo].[SDRPTS] ([GDGID], [FILDATE], [CLS], [SND]) ON [PRIMARY]
GO
