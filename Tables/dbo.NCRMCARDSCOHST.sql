CREATE TABLE [dbo].[NCRMCARDSCOHST]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARRIER] [int] NOT NULL CONSTRAINT [DF__NCRMCARDS__CARRI__0E273B58] DEFAULT (1),
[SCORESUBJECT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCRMCARDS__SCORE__0F1B5F91] DEFAULT ('未知'),
[OLDSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCRMCARDS__OLDSC__100F83CA] DEFAULT (0),
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCRMCARDS__SCORE__1103A803] DEFAULT (0),
[FGSTAT] [smallint] NOT NULL CONSTRAINT [DF__NCRMCARDS__FGSTA__11F7CC3C] DEFAULT (0),
[NUM] [char] (26) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCORESORT] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCRMCARDS__SCORE__12EBF075] DEFAULT ('-'),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCRMCARDSCOHST] ADD CONSTRAINT [PK__NCRMCARDSCOHST__13E014AE] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
