CREATE TABLE [dbo].[Spcvdrsettledata]
(
[Settleno] [int] NOT NULL,
[Vdrgid] [int] NOT NULL,
[Vdrcode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Dept] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Brand] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Qty] [money] NULL CONSTRAINT [DF__Spcvdrsettl__Qty__7AB7A18D] DEFAULT (0),
[Dt] [money] NULL CONSTRAINT [DF__Spcvdrsettle__Dt__7BABC5C6] DEFAULT (0),
[Di] [money] NULL CONSTRAINT [DF__Spcvdrsettle__Di__7C9FE9FF] DEFAULT (0),
[Kpayrate] [int] NOT NULL,
[Klwtdt] [money] NULL CONSTRAINT [DF__Spcvdrset__Klwtd__7D940E38] DEFAULT (0),
[Kdt] [money] NULL CONSTRAINT [DF__Spcvdrsettl__Kdt__7E883271] DEFAULT (0),
[Paydt] [money] NULL CONSTRAINT [DF__Spcvdrset__Paydt__7F7C56AA] DEFAULT (0)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Spcvdrsettledata_Idx] ON [dbo].[Spcvdrsettledata] ([Settleno], [Vdrgid], [Dept]) ON [PRIMARY]
GO
