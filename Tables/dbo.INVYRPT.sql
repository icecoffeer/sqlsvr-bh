CREATE TABLE [dbo].[INVYRPT]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[CQ] [money] NULL CONSTRAINT [DF__INVYRPT__CQ__2EDBC1A8] DEFAULT (0),
[CT] [money] NULL CONSTRAINT [DF__INVYRPT__CT__2FCFE5E1] DEFAULT (0),
[FQ] [money] NULL CONSTRAINT [DF__INVYRPT__FQ__30C40A1A] DEFAULT (0),
[FT] [money] NULL CONSTRAINT [DF__INVYRPT__FT__31B82E53] DEFAULT (0),
[FINPRC] [money] NULL CONSTRAINT [DF__INVYRPT__FINPRC__32AC528C] DEFAULT (0),
[FRTLPRC] [money] NULL CONSTRAINT [DF__INVYRPT__FRTLPRC__33A076C5] DEFAULT (0),
[FDXPRC] [money] NULL CONSTRAINT [DF__INVYRPT__FDXPRC__34949AFE] DEFAULT (0),
[FPAYRATE] [money] NULL CONSTRAINT [DF__INVYRPT__FPAYRAT__3588BF37] DEFAULT (0),
[FINVPRC] [money] NULL CONSTRAINT [DF__INVYRPT__FINVPRC__367CE370] DEFAULT (0),
[FLSTINPRC] [money] NULL CONSTRAINT [DF__INVYRPT__FLSTINP__377107A9] DEFAULT (0),
[FINVCOST] [money] NOT NULL CONSTRAINT [DF__INVYRPT__FINVCOS__3B177B5B] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INVYRPT] ADD CONSTRAINT [PK__INVYRPT__035179CE] PRIMARY KEY CLUSTERED  ([ASETTLENO], [BGDGID], [BWRH], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO