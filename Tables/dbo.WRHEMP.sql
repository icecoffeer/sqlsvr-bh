CREATE TABLE [dbo].[WRHEMP]
(
[WRHGID] [int] NOT NULL,
[EMPGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WRHEMP] ADD CONSTRAINT [PK__WRHEMP__43F60EC8] PRIMARY KEY CLUSTERED  ([WRHGID], [EMPGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
