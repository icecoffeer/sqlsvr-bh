CREATE TABLE [dbo].[XFDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NULL,
[GDGID] [int] NULL,
[VALIDDATE] [datetime] NULL,
[QTY] [money] NULL CONSTRAINT [DF__XFDTL__QTY__274FAE79] DEFAULT (0),
[AMT] [money] NULL CONSTRAINT [DF__XFDTL__AMT__2843D2B2] DEFAULT (0),
[INPRC] [money] NULL CONSTRAINT [DF__XFDTL__INPRC__2937F6EB] DEFAULT (0),
[RTLPRC] [money] NULL CONSTRAINT [DF__XFDTL__RTLPRC__2A2C1B24] DEFAULT (0),
[INQTY] [money] NULL CONSTRAINT [DF__XFDTL__INQTY__2B203F5D] DEFAULT (0),
[OUTQTY] [money] NULL CONSTRAINT [DF__XFDTL__OUTQTY__2C146396] DEFAULT (0),
[INTOTAL] [money] NULL CONSTRAINT [DF__XFDTL__INTOTAL__2D0887CF] DEFAULT (0),
[OUTTOTAL] [money] NULL CONSTRAINT [DF__XFDTL__OUTTOTAL__2DFCAC08] DEFAULT (0),
[fromsubwrh] [int] NULL,
[tosubwrh] [int] NULL,
[INVCOST] [money] NOT NULL CONSTRAINT [DF__XFDTL__INVCOST__569643F5] DEFAULT (0),
[ININPRC] [money] NOT NULL CONSTRAINT [DF__XFDTL__ININPRC__578A682E] DEFAULT (0),
[INRTLPRC] [money] NOT NULL CONSTRAINT [DF__XFDTL__INRTLPRC__587E8C67] DEFAULT (0),
[TAX] [money] NOT NULL CONSTRAINT [DF__XFDTL__TAX__0E44D4E4] DEFAULT (0),
[PRICE] [money] NOT NULL CONSTRAINT [DF__XFDTL__PRICE__0F38F91D] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__XFDTL__COST__3746EA77] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XFDTL] ADD CONSTRAINT [PK__XFDTL__45DE573A] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [xfdtl_gdgid] ON [dbo].[XFDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XFDTL] ADD CONSTRAINT [在调拨单中商品不能重复] UNIQUE NONCLUSTERED  ([NUM], [GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
