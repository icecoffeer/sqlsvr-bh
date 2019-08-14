CREATE TABLE [dbo].[SYSQUERY]
(
[NAME] [char] (250) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PCODE] [text] COLLATE Chinese_PRC_CI_AS NULL,
[MODULEID] [int] NULL,
[LSTMODIFYTIME] [datetime] NULL,
[LSTMODIFIER] [char] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SYSQUERY] ADD CONSTRAINT [PK__SYSQUERY__59ED414D] PRIMARY KEY CLUSTERED  ([NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SYSQUERY_M] ON [dbo].[SYSQUERY] ([MODULEID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SYSQUERY1_M] ON [dbo].[SYSQUERY] ([MODULEID]) ON [PRIMARY]
GO