CREATE TABLE [dbo].[INPRCADJNOTIFYLAC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[PROCSTAT] [int] NOT NULL CONSTRAINT [DF__INPRCADJN__PROCS__04BE9806] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INPRCADJNOTIFYLAC] ADD CONSTRAINT [PK__INPRCADJNOTIFYLA__05B2BC3F] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO
