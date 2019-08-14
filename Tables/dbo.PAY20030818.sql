CREATE TABLE [dbo].[PAY20030818]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[FILDATE] [datetime] NULL,
[FILLER] [int] NULL,
[CHECKER] [int] NULL,
[WRH] [int] NULL,
[BILLTO] [int] NULL,
[AMT] [money] NULL,
[STAT] [smallint] NULL,
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[FROMCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[FROMNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PYTOTAL] [money] NULL,
[PRNTIME] [datetime] NULL,
[PSR] [int] NOT NULL
) ON [PRIMARY]
GO
