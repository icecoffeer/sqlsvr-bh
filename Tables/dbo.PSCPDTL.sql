CREATE TABLE [dbo].[PSCPDTL]
(
[GID] [int] NOT NULL,
[RAW] [smallint] NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL,
[EXPECTPRC] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCPDTL] ADD CONSTRAINT [PK__PSCPDTL__01342732] PRIMARY KEY CLUSTERED  ([GID], [RAW], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
