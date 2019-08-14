CREATE TABLE [dbo].[rindrpt]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BVDRGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[DQ1] [money] NULL,
[DQ2] [money] NULL,
[DQ3] [money] NULL,
[DQ4] [money] NULL,
[DT1] [money] NULL,
[DT2] [money] NULL,
[DT3] [money] NULL,
[DT4] [money] NULL,
[DI1] [money] NULL,
[DI2] [money] NULL,
[DI3] [money] NULL,
[DI4] [money] NULL,
[DR1] [money] NULL,
[DR2] [money] NULL,
[DR3] [money] NULL,
[DR4] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx1] ON [dbo].[rindrpt] ([ASTORE], [ASETTLENO], [ADATE]) ON [PRIMARY]
GO
