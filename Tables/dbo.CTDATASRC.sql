CREATE TABLE [dbo].[CTDATASRC]
(
[CODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLAG] [smallint] NOT NULL CONSTRAINT [DF__CTDATASRC__FLAG__2653CAA4] DEFAULT (0),
[HDPOSVER] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CTDATASRC__HDPOS__2747EEDD] DEFAULT ('11'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[MODALTYPE] [varchar] (2) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CTDATASRC__MODAL__76059904] DEFAULT ('02')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTDATASRC] ADD CONSTRAINT [PK__CTDATASRC__283C1316] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
