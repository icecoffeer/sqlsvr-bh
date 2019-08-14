CREATE TABLE [dbo].[buy_ret_req_payline]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[amount] [numeric] (19, 4) NULL,
[buy_return_req] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[card_code] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[currency] [int] NOT NULL,
[currency_name] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[buy_ret_req_payline] ADD CONSTRAINT [PK__buy_ret___7F4279304E93CA96] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
