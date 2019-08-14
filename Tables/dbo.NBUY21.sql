CREATE TABLE [dbo].[NBUY21]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[FAVTYPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FAVAMT] [money] NOT NULL CONSTRAINT [DF__NBUY21__FAVAMT__3F9D04AD] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__NBUY21__TAG__409128E6] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NBUY21] ADD CONSTRAINT [PK__NBUY21__3EA8E074] PRIMARY KEY CLUSTERED  ([SRC], [ID], [ITEMNO], [FAVTYPE]) ON [PRIMARY]
GO