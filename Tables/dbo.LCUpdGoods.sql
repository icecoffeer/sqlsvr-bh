CREATE TABLE [dbo].[LCUpdGoods]
(
[gdgid] [int] NOT NULL,
[Usort] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Udept] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Ubillto] [int] NULL,
[Ubrand] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Updtime] [datetime] NULL CONSTRAINT [DF__LCUpdGood__Updti__39F31102] DEFAULT (getdate()),
[Utype] [int] NOT NULL CONSTRAINT [DF__LCUpdGood__Utype__3AE7353B] DEFAULT (0)
) ON [PRIMARY]
GO
