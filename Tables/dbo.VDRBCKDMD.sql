CREATE TABLE [dbo].[VDRBCKDMD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[VENDOR] [int] NULL,
[RECCNT] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__VDRBCKDMD__FILDA__3F88C16B] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CACLDATE] [datetime] NULL,
[CANCELER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SNDDATE] [datetime] NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__VDRBCKDMD__STAT__407CE5A4] DEFAULT (0),
[CHKSTOREGID] [int] NOT NULL,
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__VDRBCKDMD__LSTUP__417109DD] DEFAULT (getdate()),
[PRNTIME] [datetime] NULL,
[PSR] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LOCKNUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[LOCKCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[EXPDATE] [datetime] NULL,
[DMDSTORE] [int] NOT NULL CONSTRAINT [DF__vdrbckdmd__DMDST__5DC32FC8] DEFAULT ((-1)),
[SRCNUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SRCCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[BCKCLS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[BEGINDATE] [datetime] NULL,
[PSRGID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRBCKDMD] ADD CONSTRAINT [PK__VDRBCKDMD__3E949D32] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
