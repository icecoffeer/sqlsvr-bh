CREATE TABLE [dbo].[CRMCARDBACKACCOUNT]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARRIER] [int] NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDBA__SCORE__66D8640D] DEFAULT (0),
[BALANCE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDBA__BALAN__67CC8846] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMCARDBACKACCOUNT] ADD CONSTRAINT [PK__CRMCARDBACKACCOU__68C0AC7F] PRIMARY KEY CLUSTERED  ([CARDNUM], [CARRIER]) ON [PRIMARY]
GO