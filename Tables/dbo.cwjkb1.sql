CREATE TABLE [dbo].[cwjkb1]
(
[FilDate] [datetime] NOT NULL,
[POSLayer] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEPTCode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEPTName] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEPLayer] [smallint] NOT NULL,
[RealAmt] [money] NOT NULL CONSTRAINT [DF__cwjkb1__RealAmt__2EBD5CC5] DEFAULT (0),
[IsUpdate] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
