CREATE TABLE [dbo].[FILEIMPORTTASK]
(
[CODE] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TBNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRCNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__FILEIMPOR__CREAT__62D9EF0E] DEFAULT (getdate()),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__FILEIMPOR__LSTUP__63CE1347] DEFAULT (getdate()),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FILEIMPORTTASK] ADD CONSTRAINT [PK__FILEIMPORTTASK__64C23780] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_FILEIMPORTTASK_NAME] ON [dbo].[FILEIMPORTTASK] ([NAME]) ON [PRIMARY]
GO
