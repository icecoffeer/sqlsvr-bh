CREATE TABLE [dbo].[RBOptionalClassInfo]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[optionalClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[individuation] [int] NOT NULL,
[locked] [tinyint] NULL,
[fonline] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBOptionalClassInfo] ADD CONSTRAINT [PK__RBOptionalClassI__230FABAA] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOptionalClassInfo_1] ON [dbo].[RBOptionalClassInfo] ([optionalClassName]) ON [PRIMARY]
GO
