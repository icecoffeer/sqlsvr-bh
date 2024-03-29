CREATE TABLE [dbo].[NPS3SPECGDSCOREPROMSUBJOUTDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[SUBJCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SUBJCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPS3SPECGDSCOREPROMSUBJOUTDTL] ADD CONSTRAINT [PK__NPS3SPECGDSCOREP__0714ED7F] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPS3SPECGDSCOREPROMSUBJOUTDTL_1] ON [dbo].[NPS3SPECGDSCOREPROMSUBJOUTDTL] ([NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPS3SPECGDSCOREPROMSUBJOUTDTL_2] ON [dbo].[NPS3SPECGDSCOREPROMSUBJOUTDTL] ([SUBJCODE]) ON [PRIMARY]
GO
