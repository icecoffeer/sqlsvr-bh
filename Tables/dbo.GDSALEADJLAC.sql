CREATE TABLE [dbo].[GDSALEADJLAC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDSALEADJLAC] ADD CONSTRAINT [PK__GDSALEADJLAC__4BA47F8D] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO
