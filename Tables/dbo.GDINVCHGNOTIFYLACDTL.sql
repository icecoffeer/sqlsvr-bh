CREATE TABLE [dbo].[GDINVCHGNOTIFYLACDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDINVCHGNOTIFYLACDTL] ADD CONSTRAINT [PK__GDINVCHGNOTIFYLA__325123E3] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO
