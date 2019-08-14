CREATE TABLE [dbo].[rvdrdrpt]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BVDRGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[DQ1] [money] NULL,
[DQ2] [money] NULL,
[DQ3] [money] NULL,
[DQ4] [money] NULL,
[DQ5] [money] NULL,
[DQ6] [money] NULL,
[DT1] [money] NULL,
[DT2] [money] NULL,
[DT3] [money] NULL,
[DT4] [money] NULL,
[DT5] [money] NULL,
[DT6] [money] NULL,
[DT7] [money] NULL,
[DI2] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_vdr] ON [dbo].[rvdrdrpt] ([ASTORE], [ASETTLENO], [ADATE]) ON [PRIMARY]
GO
