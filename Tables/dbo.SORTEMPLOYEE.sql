CREATE TABLE [dbo].[SORTEMPLOYEE]
(
[ACODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GID] [int] NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__SORTEMPLO__LSTUP__29FB09AD] DEFAULT (getdate()),
[SORTTARGET1] [money] NOT NULL CONSTRAINT [DF__SORTEMPLO__SORTT__5A5F153D] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SORTEMPLOYEE] ADD CONSTRAINT [PK__SORTEMPLOYEE__2AEF2DE6] PRIMARY KEY CLUSTERED  ([ACODE], [SCODE], [GID]) ON [PRIMARY]
GO
