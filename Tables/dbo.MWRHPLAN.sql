CREATE TABLE [dbo].[MWRHPLAN]
(
[YEAR] [decimal] (4, 0) NOT NULL,
[MONTH] [decimal] (2, 0) NOT NULL,
[WRH] [int] NOT NULL,
[TOTAL] [money] NOT NULL,
[GP] [money] NOT NULL,
[GPRATE] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MWRHPLAN] ADD CONSTRAINT [PK__MWRHPLAN__15702A09] PRIMARY KEY CLUSTERED  ([YEAR], [MONTH], [WRH]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
