CREATE TABLE [dbo].[crmscore]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL,
[MINAMOUNT] [decimal] (24, 2) NOT NULL
) ON [PRIMARY]
GO
