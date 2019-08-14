CREATE TABLE [dbo].[WEBSPOSNOCOMPARISON]
(
[SHOPCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSID] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WEBSPOSNOCOMPARISON] ADD CONSTRAINT [PK__WEBSPOSNOCOMPARI__6E3FE96B] PRIMARY KEY CLUSTERED  ([SHOPCODE], [POSNO], [POSID]) ON [PRIMARY]
GO
