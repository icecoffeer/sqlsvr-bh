CREATE TABLE [dbo].[RCPADJDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NULL,
[GDGID] [int] NULL,
[OQTY] [money] NULL,
[OTOTAL] [money] NULL,
[NQTY] [money] NULL,
[NTOTAL] [money] NULL,
[INPRC] [money] NULL,
[RTLPRC] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RCPADJDTL] ADD CONSTRAINT [PK__RCPADJDTL__0ABD916C] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [rcpadjdtl_gdgid] ON [dbo].[RCPADJDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO