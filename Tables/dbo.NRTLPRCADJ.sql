CREATE TABLE [dbo].[NRTLPRCADJ]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NRTLPRCAD__FILDA__246AB6DB] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NRTLPRCAD__RECCN__255EDB14] DEFAULT (0),
[STAT] [smallint] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NSTAT] [smallint] NOT NULL CONSTRAINT [DF__NRTLPRCAD__NSTAT__2652FF4D] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RCV] [int] NOT NULL,
[LAUNCH] [datetime] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NRTLPRCAD__LSTUP__27472386] DEFAULT (getdate()),
[FRCCHK] [int] NOT NULL CONSTRAINT [DF__NRTLPRCAD__FRCCH__283B47BF] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NRTLPRCADJ] ADD CONSTRAINT [PK__NRTLPRCADJ__237692A2] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NRTLPRCADJ_TYPE] ON [dbo].[NRTLPRCADJ] ([TYPE]) ON [PRIMARY]
GO
