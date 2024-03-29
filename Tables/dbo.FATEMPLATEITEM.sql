CREATE TABLE [dbo].[FATEMPLATEITEM]
(
[TEMPLATEID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DISPLAYTEXT] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[DATACONTEXT] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VISIBLE] [int] NOT NULL CONSTRAINT [DF__FATEMPLAT__VISIB__42528182] DEFAULT (1),
[MEMO] [varchar] (256) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FATEMPLATEITEM] ADD CONSTRAINT [PK__FATEMPLATEITEM__4346A5BB] PRIMARY KEY CLUSTERED  ([TEMPLATEID], [ITEMID]) ON [PRIMARY]
GO
