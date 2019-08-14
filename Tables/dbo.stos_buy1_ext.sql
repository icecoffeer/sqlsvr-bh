CREATE TABLE [dbo].[stos_buy1_ext]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[storeCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ssmvendorCode] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[ssmvendorName] [varchar] (254) COLLATE Chinese_PRC_CI_AS NULL,
[ssmassistantCode] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[ssmassistantName] [varchar] (254) COLLATE Chinese_PRC_CI_AS NULL,
[ssmaccountCheckCardNum] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ssmempCode] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[ssmempName] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stos_buy1_ext] ADD CONSTRAINT [PK__stos_buy__7F4279306FBFB437] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
