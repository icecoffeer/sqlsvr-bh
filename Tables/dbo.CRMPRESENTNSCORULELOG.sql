CREATE TABLE [dbo].[CRMPRESENTNSCORULELOG]
(
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMPRESEN__OPERT__2153E26F] DEFAULT (getdate())
) ON [PRIMARY]
GO
