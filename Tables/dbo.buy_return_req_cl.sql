CREATE TABLE [dbo].[buy_return_req_cl]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[amount] [numeric] (19, 4) NULL,
[buy_return_req] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[card_code] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[currency] [int] NOT NULL,
[currency_name] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[buy_return_req_cl] ADD CONSTRAINT [PK__buy_retu__7F427930249D90CA] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
