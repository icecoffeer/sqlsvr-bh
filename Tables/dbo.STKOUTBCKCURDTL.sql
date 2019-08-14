CREATE TABLE [dbo].[STKOUTBCKCURDTL]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CURRENCY] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [money] NOT NULL CONSTRAINT [DF__STKOUTBCK__AMOUN__0EB07FE6] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STKOUTBCKCURDTL] ADD CONSTRAINT [PK__STKOUTBCKCURDTL__247D636F] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [CURRENCY]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
