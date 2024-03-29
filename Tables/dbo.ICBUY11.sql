CREATE TABLE [dbo].[ICBUY11]
(
[STORE] [int] NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[CURRENCY] [smallint] NOT NULL CONSTRAINT [DF__ICBUY11__CURRENC__36C7C78A] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICBUY11__AMOUNT__37BBEBC3] DEFAULT (0),
[CARDCODE] [char] (128) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ICBUY11] ADD CONSTRAINT [PK__ICBUY11__35D3A351] PRIMARY KEY CLUSTERED  ([STORE], [POSNO], [FLOWNO], [ITEMNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
