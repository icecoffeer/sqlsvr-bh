CREATE TABLE [dbo].[FTPSEQNAME]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[SEQNO] [int] NULL,
[NAME] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FTPSEQNAME] ADD CONSTRAINT [PK__FTPSEQNAME__55CF6A4A] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
