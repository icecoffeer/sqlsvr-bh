CREATE TABLE [dbo].[BLPREORDLAC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[TAG] [int] NOT NULL CONSTRAINT [DF__BLPREORDLAC__TAG__27671F17] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BLPREORDLAC] ADD CONSTRAINT [PK__BLPREORDLAC__2672FADE] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO