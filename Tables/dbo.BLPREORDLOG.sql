CREATE TABLE [dbo].[BLPREORDLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACT] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BLPREORDLOG] ADD CONSTRAINT [PK__BLPREORDLOG__294F6789] PRIMARY KEY CLUSTERED  ([NUM], [STAT], [TIME]) ON [PRIMARY]
GO
