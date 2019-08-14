CREATE TABLE [dbo].[rprocdrpt]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BWRH] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[DQ1] [money] NOT NULL,
[DT1] [money] NOT NULL,
[DI1] [money] NOT NULL,
[DR1] [money] NOT NULL,
[DD1] [money] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx1] ON [dbo].[rprocdrpt] ([ASTORE], [ASETTLENO], [ADATE]) ON [PRIMARY]
GO
