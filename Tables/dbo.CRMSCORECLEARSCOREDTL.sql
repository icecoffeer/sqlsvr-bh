CREATE TABLE [dbo].[CRMSCORECLEARSCOREDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSCORECLEARSCOREDTL] ADD CONSTRAINT [PK__CRMSCORECLEARSCO__4AFB3F6E] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [CARDNUM]) ON [PRIMARY]
GO
