CREATE TABLE [dbo].[应付帐款日报表]
(
[adate] [datetime] NOT NULL,
[vdrgid] [int] NOT NULL,
[gdgid] [int] NOT NULL,
[QtyIn] [money] NOT NULL CONSTRAINT [DF__应付帐款日报表__QtyIn__19F74A09] DEFAULT (0),
[TotalIn] [money] NOT NULL CONSTRAINT [DF__应付帐款日报表__TotalIn__1AEB6E42] DEFAULT (0),
[TRtlprcIn] [money] NOT NULL CONSTRAINT [DF__应付帐款日报表__TRtlprc__1BDF927B] DEFAULT (0),
[TInprcIn] [money] NOT NULL CONSTRAINT [DF__应付帐款日报表__TInprcI__1CD3B6B4] DEFAULT (0)
) ON [PRIMARY]
GO
