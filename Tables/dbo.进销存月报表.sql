CREATE TABLE [dbo].[进销存月报表]
(
[settleno] [int] NOT NULL,
[gdgid] [int] NOT NULL,
[Q11] [money] NULL,
[Q12] [money] NULL,
[Q21] [money] NULL,
[Q22] [money] NULL,
[Q3] [money] NULL,
[Q4] [money] NULL,
[Q5] [money] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [进销存月报表_idx] ON [dbo].[进销存月报表] ([settleno], [gdgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
