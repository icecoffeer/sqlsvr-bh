CREATE TABLE [dbo].[NBILLTOADJ]
(
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILLER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NBILLTOAD__FILLE__71E591C6] DEFAULT ('未知[-]'),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NBILLTOAD__FILDA__72D9B5FF] DEFAULT (getdate()),
[CHECKER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NBILLTOAD__RECCN__73CDDA38] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NBILLTOADJ__STAT__74C1FE71] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[LAUNCH] [datetime] NOT NULL CONSTRAINT [DF__NBILLTOAD__LAUNC__75B622AA] DEFAULT (getdate()),
[GoOnChk] [int] NOT NULL CONSTRAINT [DF__NBILLTOAD__GoOnC__76AA46E3] DEFAULT (0),
[LSTMODIFIER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NBILLTOAD__LSTMO__779E6B1C] DEFAULT ('未知[-]'),
[LstUpdTime] [datetime] NOT NULL CONSTRAINT [DF__NBILLTOAD__LstUp__78928F55] DEFAULT (getdate()),
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[TYPE] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NBILLTOADJ] ADD CONSTRAINT [PK__NBILLTOADJ__7986B38E] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO