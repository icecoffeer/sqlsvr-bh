CREATE TABLE [dbo].[EMPXLATE]
(
[NGID] [int] NOT NULL,
[LGID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EMPXLATE] ADD CONSTRAINT [PK__EMPXLATE__5772F790] PRIMARY KEY CLUSTERED  ([NGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO