CREATE TABLE [dbo].[NOTICE]
(
[SRC] [int] NOT NULL,
[GID] [int] NOT NULL,
[NAME] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ID] [int] NOT NULL CONSTRAINT [DF__NOTICE__ID__5AE6C31D] DEFAULT (0),
[LAUNCHSTORE] [int] NULL,
[count] [int] NOT NULL CONSTRAINT [DF__notice__count__5BDAE756] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NOTICE] ADD CONSTRAINT [PK__NOTICE__59F29EE4] PRIMARY KEY CLUSTERED  ([SRC], [GID], [ID]) ON [PRIMARY]
GO
