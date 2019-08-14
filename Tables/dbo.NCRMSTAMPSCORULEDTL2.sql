CREATE TABLE [dbo].[NCRMSTAMPSCORULEDTL2]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CLS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[GOODS] [int] NOT NULL,
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCRMSTAMPSCORULEDTL2] ADD CONSTRAINT [PK__NCRMSTAMPSCORULE__4E7B8EA1] PRIMARY KEY CLUSTERED  ([SRC], [ID], [NUM], [LINE]) ON [PRIMARY]
GO