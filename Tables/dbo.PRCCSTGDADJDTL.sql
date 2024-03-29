CREATE TABLE [dbo].[PRCCSTGDADJDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[OLDPRC] [decimal] (24, 2) NOT NULL,
[NEWPRC] [decimal] (24, 2) NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCCSTGDADJDTL] ADD CONSTRAINT [PK__PRCCSTGDADJDTL__59151FF2] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PRCCSTGDADJDTL_GDGID] ON [dbo].[PRCCSTGDADJDTL] ([GDGID]) ON [PRIMARY]
GO
