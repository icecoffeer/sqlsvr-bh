CREATE TABLE [dbo].[RBCartFunctionView]
(
[uuid] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[cartridge_] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[prefix] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[caption] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[isAbstract] [tinyint] NOT NULL,
[remark] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBCartFunctionView] ADD CONSTRAINT [PK__RBCartFunctionVi__28C88500] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBCartFunctionView_1] ON [dbo].[RBCartFunctionView] ([cartridge_]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBCartFunctionView_2] ON [dbo].[RBCartFunctionView] ([prefix]) ON [PRIMARY]
GO
