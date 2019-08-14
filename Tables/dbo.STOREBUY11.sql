CREATE TABLE [dbo].[STOREBUY11]
(
[STOREGID] [int] NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[CURRENCY] [smallint] NOT NULL CONSTRAINT [DF__STOREBUY1__CURRE__15A6CAE1] DEFAULT (0),
[AMOUNT] [money] NOT NULL CONSTRAINT [DF__STOREBUY1__AMOUN__169AEF1A] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__STOREBUY11__TAG__178F1353] DEFAULT (0),
[CARDCODE] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STOREBUY11] ADD CONSTRAINT [PK__STOREBUY11__14B2A6A8] PRIMARY KEY CLUSTERED  ([STOREGID], [POSNO], [FLOWNO], [ITEMNO]) ON [PRIMARY]
GO