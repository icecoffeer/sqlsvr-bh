CREATE TABLE [dbo].[INPRCADJNOTIFY]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRCSTORE] [int] NOT NULL,
[STAT] [smallint] NOT NULL,
[BGNTIME] [datetime] NOT NULL,
[ENDTIME] [datetime] NOT NULL,
[SUBTIME] [datetime] NULL,
[SUBEMP] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SUBJECT] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[EXESTAT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INPRCADJN__EXEST__00EE0722] DEFAULT (0),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[LSTRPLYTIME] [datetime] NULL,
[SNDDATE] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SRCCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[GENBILL] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GENNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[GENCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[VENDOR] [int] NOT NULL,
[ADJMETHOD] [smallint] NOT NULL,
[CANPAY] [smallint] NOT NULL,
[DIFFPROCMETHOD] [smallint] NOT NULL,
[RCVFRCCHK] [smallint] NOT NULL,
[WAITFORFIN] [smallint] NOT NULL,
[FINEXP] [datetime] NULL,
[FINISHED] [smallint] NOT NULL CONSTRAINT [DF__INPRCADJN__FINIS__01E22B5B] DEFAULT (0),
[FILLER] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[SETTLENO] [int] NOT NULL,
[TAXRATELMT] [decimal] (24, 4) NULL,
[DEPTLMT] [char] (14) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INPRCADJNOTIFY] ADD CONSTRAINT [PK__INPRCADJNOTIFY__02D64F94] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
