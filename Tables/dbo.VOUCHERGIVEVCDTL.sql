CREATE TABLE [dbo].[VOUCHERGIVEVCDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[VOUCHERNAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERNUM] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERTYPE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VOUCHERGI__AMOUN__59DA94B9] DEFAULT (0),
[ASTART] [datetime] NOT NULL,
[AFINISH] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERGIVEVCDTL] ADD CONSTRAINT [PK__VOUCHERGIVEVCDTL__5ACEB8F2] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO