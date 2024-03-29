CREATE TABLE [dbo].[VOUCHERSELLDTL]
(
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[VOUCHERNUM] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VOUCHERSE__AMOUN__54339CA0] DEFAULT (0),
[SELLAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VOUCHERSE__SELLA__5527C0D9] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERSELLDTL] ADD CONSTRAINT [PK__VOUCHERSELLDTL__561BE512] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VOUCHERSELLDTL_NUMLINE] ON [dbo].[VOUCHERSELLDTL] ([NUM], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VOUCHERSELLDTL_VOUCHERNUM] ON [dbo].[VOUCHERSELLDTL] ([VOUCHERNUM]) ON [PRIMARY]
GO
