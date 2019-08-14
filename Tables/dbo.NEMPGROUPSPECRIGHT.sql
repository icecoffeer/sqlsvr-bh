CREATE TABLE [dbo].[NEMPGROUPSPECRIGHT]
(
[ID] [int] NOT NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NEMPGROUPSP__SRC__553C041B] DEFAULT (1),
[EMPGROUPID] [int] NOT NULL,
[SPECRIGHTNO] [int] NOT NULL,
[RIGHTLEVEL] [int] NOT NULL,
[SPECRIGHTNO2] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NEMPGROUP__SPECR__56302854] DEFAULT ('-')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NEMPGROUPSPECRIGHT] ADD CONSTRAINT [PK__NEMPGROUPSPECRIG__57244C8D] PRIMARY KEY CLUSTERED  ([ID], [SRC], [EMPGROUPID], [SPECRIGHTNO], [SPECRIGHTNO2]) ON [PRIMARY]
GO