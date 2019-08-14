CREATE TABLE [dbo].[FAFAVORITE]
(
[EMPGID] [int] NOT NULL,
[ID] [int] NOT NULL,
[NAME] [varchar] (120) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PARENTID] [int] NULL,
[ITEMNO] [int] NOT NULL CONSTRAINT [DF__FAFAVORIT__ITEMN__03F627AD] DEFAULT (0),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__FAFAVORIT__LSTUP__04EA4BE6] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAFAVORITE] ADD CONSTRAINT [PK__FAFAVORITE__05DE701F] PRIMARY KEY CLUSTERED  ([EMPGID], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_FAFAVORITE_ITEM] ON [dbo].[FAFAVORITE] ([PARENTID], [ITEMNO]) ON [PRIMARY]
GO