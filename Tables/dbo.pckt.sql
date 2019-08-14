CREATE TABLE [dbo].[pckt]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[FILDATE] [datetime] NULL,
[FILLER] [int] NULL,
[WRH] [int] NULL,
[STAT] [smallint] NULL,
[RECCNT] [smallint] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
