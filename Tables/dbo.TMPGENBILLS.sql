CREATE TABLE [dbo].[TMPGENBILLS]
(
[spid] [int] NOT NULL,
[OWNER] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLNAME] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DTLCNT] [int] NOT NULL,
[STARTTIME] [datetime] NOT NULL,
[FINISHTIME] [datetime] NULL,
[STAT] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMPGENBILLS_spid] ON [dbo].[TMPGENBILLS] ([spid]) ON [PRIMARY]
GO