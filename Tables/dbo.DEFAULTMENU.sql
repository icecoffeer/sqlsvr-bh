CREATE TABLE [dbo].[DEFAULTMENU]
(
[NAME] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LEFTCHILD] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RIGHTCHILD] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODULENO] [smallint] NULL,
[TYPE] [smallint] NOT NULL CONSTRAINT [DF__DEFAULTMEN__TYPE__78B58678] DEFAULT (0),
[SHORTCUT] [char] (16) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEFAULTMENU] ADD CONSTRAINT [PK__DEFAULTMENU__408F9238] PRIMARY KEY CLUSTERED  ([NAME]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO