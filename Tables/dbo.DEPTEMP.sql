CREATE TABLE [dbo].[DEPTEMP]
(
[EMPGID] [int] NOT NULL,
[DEPTCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEPTEMP] ADD CONSTRAINT [PK__DEPTEMP__4277DAAA] PRIMARY KEY CLUSTERED  ([EMPGID], [DEPTCODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
