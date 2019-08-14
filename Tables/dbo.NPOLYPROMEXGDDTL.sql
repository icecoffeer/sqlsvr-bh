CREATE TABLE [dbo].[NPOLYPROMEXGDDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPOLYPROMEXGDDTL] ADD CONSTRAINT [PK__NPOLYPROMEXGDDTL__1FFFCB83] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO