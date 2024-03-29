CREATE TABLE [dbo].[MSALEPLAN]
(
[YEAR] [decimal] (4, 0) NOT NULL,
[MONTH] [decimal] (2, 0) NOT NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TOTAL] [money] NULL,
[GP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__MSALEPLAN__GP__7474B852] DEFAULT (0),
[GPRATE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__MSALEPLAN__GPRAT__7568DC8B] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSALEPLAN] ADD CONSTRAINT [PK__MSALEPLAN__147C05D0] PRIMARY KEY CLUSTERED  ([YEAR], [MONTH], [SORT]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
