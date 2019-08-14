CREATE TABLE [dbo].[CRMCARDSCORE]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCORESORT] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDSC__SCORE__381D7524] DEFAULT ('-'),
[SCORESUBJECT] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDSC__SCORE__3911995D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMCARDSCORE] ADD CONSTRAINT [PK__CRMCARDSCORE__3A05BD96] PRIMARY KEY CLUSTERED  ([CARDNUM], [SCORESORT], [SCORESUBJECT]) ON [PRIMARY]
GO
