CREATE TABLE [dbo].[NLMTPRM]
(
[ID] [int] NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NLMTPRM__FILDATE__11E05B9E] DEFAULT (getdate()),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__NLMTPRM__CHECKER__12D47FD7] DEFAULT (1),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NLMTPRM__RECCNT__13C8A410] DEFAULT (0),
[LMTCLS] [smallint] NOT NULL CONSTRAINT [DF__NLMTPRM__LMTCLS__14BCC849] DEFAULT (0),
[NSTAT] [smallint] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NOT NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[TYPE] [smallint] NOT NULL,
[PSETTLENO] [int] NULL,
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NLMTPRM] ADD CONSTRAINT [PK__NLMTPRM__10EC3765] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NLMTPRM_TYPE] ON [dbo].[NLMTPRM] ([TYPE]) ON [PRIMARY]
GO
