CREATE TABLE [dbo].[TAXSORTADJLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACTION] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__TAXSORTAD__ACTIO__65D6574A] DEFAULT (''),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAXSORTADJLOG] ADD CONSTRAINT [PK__TAXSORTA__83FA723867BE9FBC] PRIMARY KEY CLUSTERED  ([NUM], [STAT], [ACTION], [TIME]) ON [PRIMARY]
GO
