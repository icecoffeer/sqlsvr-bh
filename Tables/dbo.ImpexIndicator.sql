CREATE TABLE [dbo].[ImpexIndicator]
(
[uuid] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[object] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[action] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[counterPart] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[lastActionTime] [datetime] NULL,
[condTime] [datetime] NULL,
[condId] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImpexIndicator] ADD CONSTRAINT [PK__ImpexIndicator__12D943E1] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
