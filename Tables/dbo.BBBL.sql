CREATE TABLE [dbo].[BBBL]
(
[gid] [int] NOT NULL,
[inprc] [money] NOT NULL,
[rtlprc] [money] NOT NULL,
[qty] [money] NULL,
[indate] [datetime] NULL,
[inqty] [money] NULL,
[vendor] [int] NULL,
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[bbq] [money] NULL,
[todayy] [datetime] NULL,
[settleno] [int] NULL
) ON [PRIMARY]
GO
