CREATE TABLE [dbo].[CRMCARDCOSTRETDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[STORECODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORENAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDCO__AMOUN__0C3A60A6] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMCARDCOSTRETDTL] ADD CONSTRAINT [PK__CRMCARDCOSTRETDT__0D2E84DF] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
