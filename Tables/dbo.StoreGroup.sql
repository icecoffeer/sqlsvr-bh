CREATE TABLE [dbo].[StoreGroup]
(
[cls] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Code] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Name] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StoreGroup] ADD CONSTRAINT [PK__StoreGroup__6C44C29B] PRIMARY KEY CLUSTERED  ([cls], [Code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
