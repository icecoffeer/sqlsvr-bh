CREATE TABLE [dbo].[CRMSTAMPSCORULEDTL2]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CLS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[GOODS] [int] NOT NULL,
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSTAMPSCORULEDTL2] ADD CONSTRAINT [PK__CRMSTAMPSCORULED__3F4E59AA] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
