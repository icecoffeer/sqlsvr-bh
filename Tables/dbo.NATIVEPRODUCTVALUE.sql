CREATE TABLE [dbo].[NATIVEPRODUCTVALUE]
(
[CATALOG] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NATIVEPRODUCTVALUE] ADD CONSTRAINT [PK__NATIVEPRODUCTVAL__6136FB55] PRIMARY KEY CLUSTERED  ([CATALOG], [CODE]) ON [PRIMARY]
GO
