CREATE TABLE [dbo].[rb_BUY11]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[CURRENCY] [smallint] NOT NULL CONSTRAINT [DF__rb_BUY11__CURREN__27B2CE88] DEFAULT (0),
[AMOUNT] [money] NOT NULL CONSTRAINT [DF__rb_BUY11__AMOUNT__28A6F2C1] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__rb_BUY11__TAG__299B16FA] DEFAULT (0),
[CARDCODE] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rb_BUY11] ADD CONSTRAINT [PK__rb_BUY11__26BEAA4F] PRIMARY KEY CLUSTERED  ([POSNO], [FLOWNO], [ITEMNO]) ON [PRIMARY]
GO
