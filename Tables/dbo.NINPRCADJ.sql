CREATE TABLE [dbo].[NINPRCADJ]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ADJDATE] [datetime] NULL CONSTRAINT [DF__NINPRCADJ__ADJDA__055132DE] DEFAULT (getdate()),
[INBILL] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INLINE] [smallint] NULL,
[SUBWRH] [int] NULL,
[VENDOR] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[NEWPRC] [money] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NINPRCADJ__FILDA__06455717] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__NINPRCADJ__FILLE__07397B50] DEFAULT (1),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NINPRCADJ__STAT__082D9F89] DEFAULT (0),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__NINPRCADJ__CHECK__0921C3C2] DEFAULT (1),
[CHKDATE] [datetime] NULL,
[OLDSRC] [int] NOT NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__NINPRCADJ__PSR__0A15E7FB] DEFAULT (1),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NOT NULL,
[RCV] [int] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[FRCFLAG] [smallint] NOT NULL CONSTRAINT [DF__NINPRCADJ__FRCFL__0B0A0C34] DEFAULT (1),
[NNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINPRCADJ] ADD CONSTRAINT [PK__NINPRCADJ__2F2FFC0C] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NINPRCADJ_TYPE] ON [dbo].[NINPRCADJ] ([TYPE]) ON [PRIMARY]
GO