CREATE TABLE [dbo].[PRMOFFSETLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACTION] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRMOFFSETLOG] ADD CONSTRAINT [PK__PRMOFFSETLOG__575A220E] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [STAT], [ACTION], [TIME]) ON [PRIMARY]
GO
