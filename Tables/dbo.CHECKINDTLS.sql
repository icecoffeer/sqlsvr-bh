CREATE TABLE [dbo].[CHECKINDTLS]
(
[STORENO] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[THEDATE] [datetime] NOT NULL,
[CASHIER] [int] NOT NULL,
[FROMDATE] [datetime] NOT NULL,
[CURRENCY] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CHECKINDT__AMOUN__1613413A] DEFAULT (0),
[REALAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CHECKINDT__REALA__17076573] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHECKINDTLS] ADD CONSTRAINT [PK__CHECKINDTLS__151F1D01] PRIMARY KEY CLUSTERED  ([STORENO], [THEDATE], [CASHIER], [CURRENCY]) ON [PRIMARY]
GO
