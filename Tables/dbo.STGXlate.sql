CREATE TABLE [dbo].[STGXlate]
(
[cls] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Code] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[StoreGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STGXlate] ADD CONSTRAINT [PK__STGXlate__6E2D0B0D] PRIMARY KEY CLUSTERED  ([cls], [Code], [StoreGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
