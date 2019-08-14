CREATE TABLE [dbo].[NGFTPRMGIFT]
(
[RCV] [int] NOT NULL,
[ID] [int] NOT NULL,
[RCODE] [char] (18) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GROUPID] [int] NOT NULL,
[QTY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGIFT__QTY__4D2E6BFA] DEFAULT (0),
[AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGIFT__AMT__4E229033] DEFAULT (0),
[AMTLMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__AMTLM__4F16B46C] DEFAULT (0),
[SUMAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__SUMAM__500AD8A5] DEFAULT (0),
[SUMAMTLMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NGFTPRMGI__SUMAM__50FEFCDE] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NGFTPRMGIFT] ADD CONSTRAINT [PK__NGFTPRMGIFT__51F32117] PRIMARY KEY CLUSTERED  ([RCV], [ID], [RCODE], [GROUPID]) ON [PRIMARY]
GO