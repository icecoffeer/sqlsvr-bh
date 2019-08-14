CREATE TABLE [dbo].[STOREPAYOUT]
(
[STOREGID] [int] NOT NULL,
[STORERENT] [decimal] (24, 2) NULL,
[MNGPAY] [decimal] (24, 2) NULL,
[DORMRENT] [decimal] (24, 2) NULL,
[WEPAY] [decimal] (24, 2) NULL,
[EMPCOUNT] [int] NULL,
[BUSIPAY] [decimal] (24, 2) NULL,
[NTAX] [decimal] (24, 2) NULL,
[LTAX] [decimal] (24, 2) NULL,
[MATLS] [decimal] (24, 2) NULL,
[GDLS] [decimal] (24, 2) NULL,
[TELPAY] [decimal] (24, 2) NULL,
[OTHERPAY] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STOREPAYOUT] ADD CONSTRAINT [PK__STOREPAYOUT__26DF7137] PRIMARY KEY CLUSTERED  ([STOREGID]) ON [PRIMARY]
GO
