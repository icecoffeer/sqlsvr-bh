CREATE TABLE [dbo].[PRMDIRLOG]
(
[PRMSEQ] [int] NOT NULL,
[ACTION] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CONTENT] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PRMDIRLOG_PRMSEQ] ON [dbo].[PRMDIRLOG] ([PRMSEQ], [ACTION], [OPER], [TIME]) ON [PRIMARY]
GO