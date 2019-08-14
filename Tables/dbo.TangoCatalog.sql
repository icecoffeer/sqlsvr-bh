CREATE TABLE [dbo].[TangoCatalog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[code] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[itemType] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[isMaster] [tinyint] NOT NULL,
[level1Length] [int] NOT NULL,
[level2Length] [int] NOT NULL,
[level3Length] [int] NOT NULL,
[level4Length] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoCatalog] ADD CONSTRAINT [PK__TangoCatalog__1D56D254] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_catalog_1] ON [dbo].[TangoCatalog] ([domain], [code]) ON [PRIMARY]
GO
