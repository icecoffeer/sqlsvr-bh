CREATE TABLE [dbo].[NGFTPRMGIFTDTL]
(
[RCV] [int] NOT NULL,
[ID] [int] NOT NULL,
[RCODE] [char] (18) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GROUPID] [int] NOT NULL,
[GFTGID] [int] NOT NULL,
[QTY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGIFT__QTY__53DB6989] DEFAULT (0),
[QTYLMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__QTYLM__54CF8DC2] DEFAULT (0),
[SUMQTY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__SUMQT__55C3B1FB] DEFAULT (0),
[SUMQTYLMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__SUMQT__56B7D634] DEFAULT (0),
[PAYPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__PAYPR__57ABFA6D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NGFTPRMGIFTDTL] ADD CONSTRAINT [PK__NGFTPRMGIFTDTL__58A01EA6] PRIMARY KEY CLUSTERED  ([RCV], [ID], [RCODE], [GROUPID], [GFTGID]) ON [PRIMARY]
GO
