CREATE TABLE [dbo].[RBDomainFuncView]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[funcView] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[loadOrder] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBDomainFuncView] ADD CONSTRAINT [PK__RBDomainFuncView__6CB39AF9] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBDomainFuncView_1] ON [dbo].[RBDomainFuncView] ([domain], [funcView]) ON [PRIMARY]
GO
