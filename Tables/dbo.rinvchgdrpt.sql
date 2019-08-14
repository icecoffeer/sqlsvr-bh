CREATE TABLE [dbo].[rinvchgdrpt]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[DQ1] [money] NULL,
[DQ2] [money] NULL,
[DQ4] [money] NULL,
[DQ5] [money] NULL,
[DI1] [money] NULL,
[DI2] [money] NULL,
[DI3] [money] NULL,
[DI4] [money] NULL,
[DI5] [money] NULL,
[DR1] [money] NULL,
[DR2] [money] NULL,
[DR3] [money] NULL,
[DR4] [money] NULL,
[DR5] [money] NULL,
[DQ6] [money] NOT NULL,
[DQ7] [money] NOT NULL,
[DT6] [money] NOT NULL,
[DT7] [money] NOT NULL,
[DI6] [money] NOT NULL,
[DI7] [money] NOT NULL,
[DR6] [money] NOT NULL,
[DR7] [money] NOT NULL,
[DI8] [money] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx1] ON [dbo].[rinvchgdrpt] ([ASTORE], [ASETTLENO], [ADATE]) ON [PRIMARY]
GO
