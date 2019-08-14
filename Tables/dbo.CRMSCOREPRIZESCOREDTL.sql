CREATE TABLE [dbo].[CRMSCOREPRIZESCOREDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[HSTNUM] [char] (26) COLLATE Chinese_PRC_CI_AS NOT NULL,
[REVSCORE] [decimal] (24, 2) NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL,
[SCORESORT] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMSCOREP__SCORE__24D59686] DEFAULT ('-')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSCOREPRIZESCOREDTL] ADD CONSTRAINT [PK__CRMSCOREPRIZESCO__25C9BABF] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
