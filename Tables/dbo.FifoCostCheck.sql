CREATE TABLE [dbo].[FifoCostCheck]
(
[ASETTLENO] [int] NULL,
[ADATE] [datetime] NOT NULL,
[GDGID] [int] NOT NULL,
[lastcostQTY] [money] NOT NULL CONSTRAINT [DF__FifoCostC__lastc__15B28330] DEFAULT (0),
[lastcosttotal] [money] NOT NULL CONSTRAINT [DF__FifoCostC__lastc__16A6A769] DEFAULT (0),
[costqty] [money] NOT NULL CONSTRAINT [DF__FifoCostC__costq__179ACBA2] DEFAULT (0),
[costtotal] [money] NOT NULL CONSTRAINT [DF__FifoCostC__costt__188EEFDB] DEFAULT (0),
[zjqty] [money] NOT NULL CONSTRAINT [DF__FifoCostC__zjqty__19831414] DEFAULT (0),
[zjtotal] [money] NOT NULL CONSTRAINT [DF__FifoCostC__zjtot__1A77384D] DEFAULT (0),
[zjtqty] [money] NOT NULL CONSTRAINT [DF__FifoCostC__zjtqt__1B6B5C86] DEFAULT (0),
[zjttotal] [money] NOT NULL CONSTRAINT [DF__FifoCostC__zjtto__1C5F80BF] DEFAULT (0),
[outqty] [money] NOT NULL CONSTRAINT [DF__FifoCostC__outqt__1D53A4F8] DEFAULT (0),
[outtotal] [money] NOT NULL CONSTRAINT [DF__FifoCostC__outto__1E47C931] DEFAULT (0),
[indj] [money] NOT NULL CONSTRAINT [DF__FifoCostCh__indj__1F3BED6A] DEFAULT (0),
[invadjqty] [money] NOT NULL CONSTRAINT [DF__FifoCostC__invad__203011A3] DEFAULT (0),
[invadjtotal] [money] NOT NULL CONSTRAINT [DF__FifoCostC__invad__212435DC] DEFAULT (0),
[outcost] [money] NOT NULL CONSTRAINT [DF__FifoCostC__outco__22185A15] DEFAULT (0),
[inprc] [money] NOT NULL CONSTRAINT [DF__FifoCostC__inprc__230C7E4E] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FifoCostCheck] ADD CONSTRAINT [PK__FifoCostCheck__5A4F643B] PRIMARY KEY CLUSTERED  ([ADATE], [GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
