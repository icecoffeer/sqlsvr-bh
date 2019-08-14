CREATE TABLE [dbo].[POSMONEYRCD]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__POSMONEYR__FILDA__72F1C02A] DEFAULT (getdate()),
[CURRENCY] [smallint] NOT NULL,
[CASHIER] [int] NOT NULL,
[OPER] [int] NOT NULL,
[AMOUNT] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POSMONEYRCD] ADD CONSTRAINT [PK__POSMONEYRCD__71FD9BF1] PRIMARY KEY CLUSTERED  ([CLS], [POSNO], [FILDATE], [CURRENCY]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO