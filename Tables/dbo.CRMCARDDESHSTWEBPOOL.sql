CREATE TABLE [dbo].[CRMCARDDESHSTWEBPOOL]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARRIER] [int] NOT NULL CONSTRAINT [DF__CRMCARDDE__CARRI__20CFFB78] DEFAULT (1),
[OLDBAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDDE__OLDBA__21C41FB1] DEFAULT (0),
[OCCUR] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDDE__OCCUR__22B843EA] DEFAULT (0),
[NUM] [char] (26) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CRMCARDDESHSTWEBPOOL_NUM] ON [dbo].[CRMCARDDESHSTWEBPOOL] ([NUM]) ON [PRIMARY]
GO
