CREATE TABLE [dbo].[NINVMRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[BGDGID] [int] NULL,
[BWRH] [int] NULL,
[CQ] [money] NULL CONSTRAINT [DF__NINVMRPT__CQ__1ABFBA62] DEFAULT (0),
[CT] [money] NULL CONSTRAINT [DF__NINVMRPT__CT__1BB3DE9B] DEFAULT (0),
[FQ] [money] NULL CONSTRAINT [DF__NINVMRPT__FQ__1CA802D4] DEFAULT (0),
[FT] [money] NULL CONSTRAINT [DF__NINVMRPT__FT__1D9C270D] DEFAULT (0),
[FINPRC] [money] NULL CONSTRAINT [DF__NINVMRPT__FINPRC__1E904B46] DEFAULT (0),
[FRTLPRC] [money] NULL CONSTRAINT [DF__NINVMRPT__FRTLPR__1F846F7F] DEFAULT (0),
[FDXPRC] [money] NULL CONSTRAINT [DF__NINVMRPT__FDXPRC__207893B8] DEFAULT (0),
[FPAYRATE] [money] NULL CONSTRAINT [DF__NINVMRPT__FPAYRA__216CB7F1] DEFAULT (0),
[FINVPRC] [money] NULL CONSTRAINT [DF__NINVMRPT__FINVPR__2260DC2A] DEFAULT (0),
[FLSTINPRC] [money] NULL CONSTRAINT [DF__NINVMRPT__FLSTIN__23550063] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL,
[FINVCOST] [money] NOT NULL CONSTRAINT [DF__NINVMRPT__FINVCO__3CFFC3CD] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINVMRPT] ADD CONSTRAINT [PK__NINVMRPT__36D11DD4] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO