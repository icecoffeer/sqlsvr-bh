CREATE TABLE [dbo].[CRMSCOREPRIZECARDDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCORESORT] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMSCOREP__SCORE__1E2898F7] DEFAULT ('-'),
[REVSCORE] [decimal] (24, 2) NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL,
[CARDREVSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMSCOREP__CARDR__1F1CBD30] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSCOREPRIZECARDDTL] ADD CONSTRAINT [PK__CRMSCOREPRIZECAR__2010E169] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO