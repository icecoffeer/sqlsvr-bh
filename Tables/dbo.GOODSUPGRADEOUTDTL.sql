CREATE TABLE [dbo].[GOODSUPGRADEOUTDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[CASES] [decimal] (24, 4) NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[PRICE] [decimal] (24, 4) NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[TAX] [decimal] (24, 2) NOT NULL,
[WRH] [int] NOT NULL,
[INPRC] [decimal] (24, 4) NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[SNEWFLAG] [smallint] NULL,
[SALE] [int] NULL,
[BILLTO] [int] NULL,
[TAXRATE] [decimal] (24, 4) NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GOODSUPGRADEOUTDTL] ADD CONSTRAINT [PK__GOODSUPGRADEOUTD__7601D21B] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
