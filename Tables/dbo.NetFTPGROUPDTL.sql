CREATE TABLE [dbo].[NetFTPGROUPDTL]
(
[GRPID] [int] NOT NULL,
[OID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NetFTPGROUPDTL] ADD CONSTRAINT [PK__NetFTPGROUPDTL__6C072D7E] PRIMARY KEY CLUSTERED  ([GRPID], [OID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NetFTPGROUPDTL] ADD CONSTRAINT [IDX_NETFTPGROUPDTL] UNIQUE NONCLUSTERED  ([OID]) ON [PRIMARY]
GO
