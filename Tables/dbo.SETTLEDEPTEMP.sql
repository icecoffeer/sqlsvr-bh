CREATE TABLE [dbo].[SETTLEDEPTEMP]
(
[EMPGID] [int] NOT NULL,
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SETTLEDEPTEMP] ADD CONSTRAINT [PK__SETTLEDEPTEMP__0C93F8A1] PRIMARY KEY CLUSTERED  ([CODE], [EMPGID]) ON [PRIMARY]
GO
