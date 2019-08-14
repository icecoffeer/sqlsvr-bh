CREATE TABLE [dbo].[NBCKDMD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[RECCNT] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NBCKDMD__FILDATE__23EAC897] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CACLDATE] [datetime] NULL,
[CANCELER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SNDDATE] [datetime] NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NBCKDMD__STAT__24DEECD0] DEFAULT (0),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [int] NOT NULL,
[NNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NBCKDMD__LSTUPDT__25D31109] DEFAULT (getdate()),
[PSR] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[EXPDATE] [datetime] NULL,
[BCKCLS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[DMDSTORE] [int] NOT NULL CONSTRAINT [DF__nbckdmd__DMDSTOR__609F9C73] DEFAULT ((-1)),
[SRCNUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SRCCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[BEGINDATE] [datetime] NULL,
[PSRGID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NBCKDMD] ADD CONSTRAINT [PK__NBCKDMD__22F6A45E] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO