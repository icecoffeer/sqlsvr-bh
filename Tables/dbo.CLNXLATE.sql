CREATE TABLE [dbo].[CLNXLATE]
(
[NGID] [int] NOT NULL,
[LGID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLNXLATE] ADD CONSTRAINT [PK__CLNXLATE__2E70E1FD] PRIMARY KEY CLUSTERED  ([NGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
