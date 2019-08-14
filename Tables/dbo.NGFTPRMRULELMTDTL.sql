CREATE TABLE [dbo].[NGFTPRMRULELMTDTL]
(
[RCV] [int] NOT NULL,
[ID] [int] NOT NULL,
[RCODE] [char] (18) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LMTNO] [int] NOT NULL,
[LINE] [int] NOT NULL,
[NAME] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VALUE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NGFTPRMRULELMTDTL] ADD CONSTRAINT [PK__NGFTPRMRULELMTDT__477592A4] PRIMARY KEY CLUSTERED  ([RCV], [ID], [RCODE], [LMTNO], [LINE]) ON [PRIMARY]
GO
