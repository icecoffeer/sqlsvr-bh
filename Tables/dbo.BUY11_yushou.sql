CREATE TABLE [dbo].[BUY11_yushou]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[CURRENCY] [smallint] NOT NULL CONSTRAINT [DF__BUY11_yus__CURRE__63426CB4] DEFAULT (0),
[AMOUNT] [money] NOT NULL CONSTRAINT [DF__BUY11_yus__AMOUN__643690ED] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__BUY11_yusho__TAG__652AB526] DEFAULT (0),
[CARDCODE] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[FAVTYPE] [varchar] (4) COLLATE Chinese_PRC_CI_AS NULL,
[FAVAMT] [money] NULL,
[PARVALUE] [money] NULL,
[ORIGINALAMT] [money] NULL,
[CURRENCYTYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PARITIES] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUY11_yushou] ADD CONSTRAINT [PK__BUY11_yushou__624E487B] PRIMARY KEY CLUSTERED  ([POSNO], [FLOWNO], [ITEMNO]) ON [PRIMARY]
GO