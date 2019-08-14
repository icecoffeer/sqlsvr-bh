CREATE TABLE [dbo].[RBOptionCollection]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[optionalClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fuser] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[locked] [tinyint] NULL,
[fonline] [tinyint] NULL,
[inherited] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBOptionCollection] ADD CONSTRAINT [PK__RBOptionCollecti__1F3F1AC6] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOptionCollection_1] ON [dbo].[RBOptionCollection] ([domain], [optionalClassName], [fuser]) ON [PRIMARY]
GO
