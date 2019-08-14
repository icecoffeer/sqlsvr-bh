CREATE TABLE [dbo].[PayImpDtl]
(
[spid] [int] NOT NULL,
[VDRGID] [int] NOT NULL,
[BNUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GDGID] [int] NOT NULL,
[SALE] [int] NULL,
[TAXRATE] [decimal] (24, 4) NULL,
[QTY] [decimal] (24, 4) NULL,
[NPQTY] [decimal] (24, 4) NULL,
[TOTAL] [decimal] (24, 4) NULL,
[NPTOTAL] [decimal] (24, 4) NULL,
[STOTAL] [decimal] (24, 4) NULL,
[NPSTOTAL] [decimal] (24, 4) NULL,
[INPRC] [decimal] (24, 4) NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[FROMNUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FROMLINE] [int] NULL,
[FROMCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FROMTOTAL] [decimal] (24, 4) NULL,
[FromPayDate] [datetime] NULL,
[GDWRH] [int] NULL,
[GDF1] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLEDEPT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PAYNUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayImpDtl_spid] ON [dbo].[PayImpDtl] ([spid]) ON [PRIMARY]
GO
