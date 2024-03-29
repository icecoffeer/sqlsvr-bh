CREATE TABLE [dbo].[BANKRECONTAB]
(
[FUUID] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORECODE] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CASHIER] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MERCHANTNO] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TERMINALNO] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BATCHNO] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[FLOWNO] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[REFERENCENO] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TRADEDATE] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[AMOUNT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BANKRECON__AMOUN__6672486C] DEFAULT (0),
[CARDNO] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CARDTYPE] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CARDNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BANKRECONTAB] ADD CONSTRAINT [PK__BANKRECONTAB__67666CA5] PRIMARY KEY CLUSTERED  ([FUUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TRADEDATE] ON [dbo].[BANKRECONTAB] ([TRADEDATE]) ON [PRIMARY]
GO
