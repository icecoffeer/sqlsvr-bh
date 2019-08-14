CREATE TABLE [dbo].[rinvdrpt]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[CQ] [money] NULL,
[CT] [money] NULL,
[FQ] [money] NULL,
[FT] [money] NULL,
[FINPRC] [money] NULL,
[FRTLPRC] [money] NULL,
[FDXPRC] [money] NULL,
[FPAYRATE] [money] NULL,
[FINVPRC] [money] NULL,
[FLSTINPRC] [money] NULL,
[FINVCOST] [money] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_inv] ON [dbo].[rinvdrpt] ([ADATE], [ASETTLENO], [ASTORE]) ON [PRIMARY]
GO
