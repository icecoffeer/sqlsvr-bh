CREATE TABLE [dbo].[CRMSCOPRIZGOODS]
(
[GDGID] [int] NOT NULL,
[STORECODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BGNTIME] [datetime] NOT NULL,
[ENDTIME] [datetime] NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMSCOPRI__SCORE__4B4A1C3B] DEFAULT (0),
[SCORESORT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMSCOPRI__SCORE__4C3E4074] DEFAULT ('-'),
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (120) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SPEC] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[UNIT] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NULL CONSTRAINT [DF__CRMSCOPRI__LSTUP__4D3264AD] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSCOPRIZGOODS] ADD CONSTRAINT [PK__CRMSCOPRIZGOODS__4E2688E6] PRIMARY KEY CLUSTERED  ([GDGID], [STORECODE], [BGNTIME]) ON [PRIMARY]
GO