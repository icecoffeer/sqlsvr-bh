CREATE TABLE [dbo].[PSGOODSEX]
(
[GID] [int] NOT NULL,
[ICONFILE] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[IMAGEFILE] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[ICONFILEUUID] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[IMAGEFILEUUID] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[ICONLSTTIME] [datetime] NULL,
[IMAGELSTTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSGOODSEX] ADD CONSTRAINT [PK__PSGOODSEX__2812C13B] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
