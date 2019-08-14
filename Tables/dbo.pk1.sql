CREATE TABLE [dbo].[pk1]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL,
[TOTAL] [money] NOT NULL,
[CKNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CKLINE] [smallint] NULL,
[SUBWRH] [int] NULL
) ON [PRIMARY]
GO
