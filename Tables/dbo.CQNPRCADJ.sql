CREATE TABLE [dbo].[CQNPRCADJ]
(
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNPRCADJ__NSTAT__5603A91D] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNPRCADJ__EXTIM__56F7CD56] DEFAULT (getdate()),
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[FILDATE] [datetime] NOT NULL,
[FILLER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [int] NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__CQNPRCADJ__PSR__57EBF18F] DEFAULT (1),
[STAT] [smallint] NOT NULL,
[LAUNCH] [datetime] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PRNTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NULL,
[SNDTIME] [datetime] NULL,
[RECCNT] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNPRCADJ] ADD CONSTRAINT [PK__CQNPRCADJ__550F84E4] PRIMARY KEY CLUSTERED  ([NTYPE], [GROUPID]) ON [PRIMARY]
GO