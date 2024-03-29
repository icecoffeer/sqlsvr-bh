CREATE TABLE [dbo].[LMTPRICEHST]
(
[LSTID] [char] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[LMTCLS] [smallint] NOT NULL CONSTRAINT [DF__LMTPRICEH__LMTCL__24F33012] DEFAULT (0),
[GDGID] [int] NOT NULL,
[ASTART] [datetime] NOT NULL CONSTRAINT [DF__LMTPRICEH__ASTAR__25E7544B] DEFAULT (getdate()),
[AFINISH] [datetime] NOT NULL CONSTRAINT [DF__LMTPRICEH__AFINI__26DB7884] DEFAULT ('9999.12.31 23:59:59'),
[QTYLMT] [money] NOT NULL CONSTRAINT [DF__LMTPRICEH__QTYLM__27CF9CBD] DEFAULT (0),
[PRICE] [money] NOT NULL,
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CANCELDATE] [datetime] NOT NULL CONSTRAINT [DF__LMTPRICEH__CANCE__28C3C0F6] DEFAULT ('1899.12.31 23:59:59')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LMTPRICEHST] ADD CONSTRAINT [PK__LMTPRICEHST__23FF0BD9] PRIMARY KEY NONCLUSTERED  ([LSTID], [STOREGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
