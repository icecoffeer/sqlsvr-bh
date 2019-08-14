CREATE TABLE [dbo].[PSGDLISTDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[GDQPC] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSGDLISTDTL] ADD CONSTRAINT [PK__PSGDLISTDTL__356CBC59] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INDEX_PSGDLISTDTL_GDGID] ON [dbo].[PSGDLISTDTL] ([GDGID]) ON [PRIMARY]
GO
