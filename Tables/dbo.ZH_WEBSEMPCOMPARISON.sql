CREATE TABLE [dbo].[ZH_WEBSEMPCOMPARISON]
(
[SHOPCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSID] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CASHIER] [int] NOT NULL,
[ASSISTANT] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ZH_WEBSEMPCOMPARISON] ADD CONSTRAINT [PK__ZH_WEBSEMPCOMPAR__277866C7] PRIMARY KEY CLUSTERED  ([SHOPCODE], [POSID]) ON [PRIMARY]
GO
