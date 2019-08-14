CREATE TABLE [dbo].[PSMKTIVGTDTLDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[ITEMNO] [int] NOT NULL,
[PROPCODE] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PROPNAME] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VALUE] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSMKTIVGTDTLDTL] ADD CONSTRAINT [PK__PSMktIvgtDtlDtl__653AFFB5] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [ITEMNO]) ON [PRIMARY]
GO