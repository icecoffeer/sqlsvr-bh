CREATE TABLE [dbo].[NCTDATASRC]
(
[CODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLAG] [smallint] NOT NULL CONSTRAINT [DF__NCTDATASRC__FLAG__14377C6E] DEFAULT (0),
[HDPOSVER] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTDATASR__HDPOS__152BA0A7] DEFAULT ('11'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[MODALTYPE] [varchar] (2) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTDATASR__MODAL__161FC4E0] DEFAULT ('02'),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTDATASRC] ADD CONSTRAINT [PK__NCTDATASRC__1713E919] PRIMARY KEY CLUSTERED  ([SRC], [ID], [CODE]) ON [PRIMARY]
GO
