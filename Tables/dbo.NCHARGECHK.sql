CREATE TABLE [dbo].[NCHARGECHK]
(
[ID] [int] NOT NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHARGEDATE] [datetime] NOT NULL,
[SALETYPE] [int] NOT NULL CONSTRAINT [DF__NCHARGECH__SALET__73BFBFE4] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NCHARGECHK__STAT__74B3E41D] DEFAULT (0),
[FILLER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL,
[CHECKER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SHOULDRCVTOTALT0] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCHARGECH__SHOUL__75A80856] DEFAULT (0),
[SHOULDRCVTOTALT1] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCHARGECH__SHOUL__769C2C8F] DEFAULT (0),
[RCVTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCHARGECH__RCVTO__779050C8] DEFAULT (0),
[OTHERTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCHARGECH__OTHER__78847501] DEFAULT (0),
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[TYPE] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCHARGECHK] ADD CONSTRAINT [PK__NCHARGECHK__7978993A] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPAYRATEPRM_TYPE] ON [dbo].[NCHARGECHK] ([TYPE]) ON [PRIMARY]
GO
