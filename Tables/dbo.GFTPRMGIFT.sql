CREATE TABLE [dbo].[GFTPRMGIFT]
(
[RCODE] [char] (18) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GROUPID] [int] NOT NULL,
[QTY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GFTPRMGIFT__QTY__688AD6FE] DEFAULT (0),
[AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GFTPRMGIFT__AMT__697EFB37] DEFAULT (0),
[AMTLMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GFTPRMGIF__AMTLM__6A731F70] DEFAULT (0),
[SUMAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GFTPRMGIF__SUMAM__6B6743A9] DEFAULT (0),
[SUMAMTLMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GFTPRMGIF__SUMAM__6C5B67E2] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GFTPRMGIFT] ADD CONSTRAINT [PK__GFTPRMGIFT__6796B2C5] PRIMARY KEY CLUSTERED  ([RCODE], [GROUPID]) ON [PRIMARY]
GO
