CREATE TABLE [dbo].[menut]
(
[NAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LEFTCHILD] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RIGHTCHILD] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODULENO] [smallint] NULL,
[TYPE] [smallint] NOT NULL,
[SHORTCUT] [char] (16) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
