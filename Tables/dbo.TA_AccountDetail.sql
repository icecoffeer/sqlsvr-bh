CREATE TABLE [dbo].[TA_AccountDetail]
(
[RELATIONID] [int] NOT NULL,
[Condition] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AccountCode] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ACCOUNTNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TA_AccountDetail] ADD CONSTRAINT [UQ__TA_AccountDetail__75D84E76] UNIQUE NONCLUSTERED  ([RELATIONID], [Condition]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO