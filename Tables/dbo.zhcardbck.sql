CREATE TABLE [dbo].[zhcardbck]
(
[posno] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[flowno] [char] (12) COLLATE Chinese_PRC_CI_AS NULL,
[date] [datetime] NULL,
[cardno] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[oldtraceno] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[total] [money] NOT NULL CONSTRAINT [DF__zhcardbck__total__41903A17] DEFAULT (0),
[traceno] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[amount] [money] NULL,
[empcode] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
