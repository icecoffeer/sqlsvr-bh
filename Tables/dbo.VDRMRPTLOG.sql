CREATE TABLE [dbo].[VDRMRPTLOG]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BVDRGID] [int] NOT NULL,
[MWRH] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[SALE] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRMRPTLOG] ADD CONSTRAINT [PK__VDRMRPTLOG__39788055] PRIMARY KEY CLUSTERED  ([ASTORE], [ASETTLENO], [MWRH], [BGDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
