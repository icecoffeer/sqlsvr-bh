CREATE TABLE [dbo].[RBCartridge]
(
[uuid] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[prefix] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[caption] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[version] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[upgrading] [tinyint] NOT NULL,
[remark] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBCartridge] ADD CONSTRAINT [PK__RBCartridge__26E03C8E] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
