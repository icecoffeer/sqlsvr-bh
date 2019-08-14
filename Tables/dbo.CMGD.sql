CREATE TABLE [dbo].[CMGD]
(
[CMCODE] [char] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[PRIORITY] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LISTNO] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMGD] ADD CONSTRAINT [PK__CMGD__24181325] PRIMARY KEY CLUSTERED  ([CMCODE], [LISTNO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CMGD_CG] ON [dbo].[CMGD] ([CMCODE], [GDGID]) ON [PRIMARY]
GO
