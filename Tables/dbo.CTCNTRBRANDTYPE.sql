CREATE TABLE [dbo].[CTCNTRBRANDTYPE]
(
[GID] [smallint] NOT NULL,
[NAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRBRANDTYPE] ADD CONSTRAINT [PK__CTCNTRBRANDTYPE__3B7CFD6F] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_CTCNTRBRANDTYPE_NAME] ON [dbo].[CTCNTRBRANDTYPE] ([NAME]) ON [PRIMARY]
GO
