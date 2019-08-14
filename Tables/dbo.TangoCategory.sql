CREATE TABLE [dbo].[TangoCategory]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[catalog] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[code] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[usedType] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[parent] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[remark] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoCategory] ADD CONSTRAINT [PK__TangoCategory__14C18C53] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_category_1] ON [dbo].[TangoCategory] ([domain], [code]) ON [PRIMARY]
GO
