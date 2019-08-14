CREATE TABLE [dbo].[NCNTRDPTBILL]
(
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRDPTB__TOTAL__742A9F8F] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NCNTRDPTBI__STAT__751EC3C8] DEFAULT (0),
[VDROPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCNTRDPTB__CHECK__7612E801] DEFAULT (1),
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__NCNTRDPTBIL__PSR__77070C3A] DEFAULT (1),
[PAYER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[TOTALOFF] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRDPTB__TOTAL__77FB3073] DEFAULT (0),
[STSTORE] [int] NULL,
[CLECENT] [int] NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NCNTRDPTBIL__SRC__78EF54AC] DEFAULT (0),
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RCV] [int] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[CFLAG] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCNTRDPTBILL] ADD CONSTRAINT [PK__NCNTRDPTBILL__79E378E5] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO