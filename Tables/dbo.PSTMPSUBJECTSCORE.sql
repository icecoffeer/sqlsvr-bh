CREATE TABLE [dbo].[PSTMPSUBJECTSCORE]
(
[spid] [int] NOT NULL,
[SORT] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SUBJECT] [char] (3) COLLATE Chinese_PRC_CI_AS NULL,
[SCORE] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PSTMPSUBJECTSCORE_spid] ON [dbo].[PSTMPSUBJECTSCORE] ([spid]) ON [PRIMARY]
GO
