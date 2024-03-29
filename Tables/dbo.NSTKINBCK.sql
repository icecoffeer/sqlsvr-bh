CREATE TABLE [dbo].[NSTKINBCK]
(
[ID] [int] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__NSTKINBCK__CLS__3C15C135] DEFAULT ('自营'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[VENDOR] [int] NULL CONSTRAINT [DF__NSTKINBCK__VENDO__3D09E56E] DEFAULT (1),
[VENDORNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTO] [int] NULL CONSTRAINT [DF__NSTKINBCK__BILLT__3DFE09A7] DEFAULT (1),
[OCRDATE] [datetime] NULL CONSTRAINT [DF__NSTKINBCK__OCRDA__3EF22DE0] DEFAULT (getdate()),
[TOTAL] [money] NULL CONSTRAINT [DF__NSTKINBCK__TOTAL__3FE65219] DEFAULT (0),
[TAX] [money] NULL CONSTRAINT [DF__NSTKINBCK__TAX__40DA7652] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NULL CONSTRAINT [DF__NSTKINBCK__FILDA__41CE9A8B] DEFAULT (getdate()),
[CHECKER] [int] NULL CONSTRAINT [DF__NSTKINBCK__CHECK__42C2BEC4] DEFAULT (1),
[STAT] [smallint] NULL CONSTRAINT [DF__NSTKINBCK__STAT__43B6E2FD] DEFAULT (1),
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PSR] [int] NULL CONSTRAINT [DF__NSTKINBCK__PSR__44AB0736] DEFAULT (1),
[RECCNT] [int] NULL CONSTRAINT [DF__NSTKINBCK__RECCN__459F2B6F] DEFAULT (0),
[SRC] [int] NOT NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NULL,
[TYPE] [smallint] NULL,
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[gencls] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[gennum] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTKINBCK] ADD CONSTRAINT [PK__NSTKINBCK__4BCC3ABA] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NSTKINBCK_TYPE] ON [dbo].[NSTKINBCK] ([TYPE]) ON [PRIMARY]
GO
