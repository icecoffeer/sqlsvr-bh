CREATE TABLE [dbo].[SORTDELETE]
(
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDCOUNT] [int] NOT NULL CONSTRAINT [DF__SORTDELET__GDCOU__14DB5EF6] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SORTDELETE] ADD CONSTRAINT [PK__SORTDELETE__15CF832F] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO