CREATE TABLE [dbo].[MENU]
(
[NAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LEFTCHILD] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RIGHTCHILD] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODULENO] [smallint] NULL,
[TYPE] [smallint] NOT NULL CONSTRAINT [DF__tmp_MENU__TYPE__1B4073FD] DEFAULT (0),
[SHORTCUT] [char] (16) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[MENU_INS] ON [dbo].[MENU] FOR INSERT, UPDATE, DELETE AS
BEGIN
	UPDATE SYSTEM SET STAMPMENU = GETDATE()
END

GO
ALTER TABLE [dbo].[MENU] ADD CONSTRAINT [PK__MENU__0DCF0841] PRIMARY KEY CLUSTERED  ([NAME]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
