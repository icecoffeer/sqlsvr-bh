CREATE TABLE [dbo].[RFBILLDTLPOOL]
(
[RFNUM] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[BARCODE] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CODETYPE] [int] NOT NULL CONSTRAINT [DF__RFBILLDTL__CODET__4F819417] DEFAULT (0),
[GID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__RFBILLDTLPO__QTY__5075B850] DEFAULT (0),
[PRICE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__RFBILLDTL__PRICE__5169DC89] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__RFBILLDTL__AMOUN__525E00C2] DEFAULT (0),
[MBRPRICE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__RFBILLDTL__MBRPR__535224FB] DEFAULT (0),
[MBRAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__RFBILLDTL__MBRAM__54464934] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFBILLDTLPOOL] ADD CONSTRAINT [PK__RFBILLDTLPOOL__553A6D6D] PRIMARY KEY CLUSTERED  ([RFNUM], [ITEMNO]) ON [PRIMARY]
GO
