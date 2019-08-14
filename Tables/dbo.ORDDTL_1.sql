CREATE TABLE [dbo].[ORDDTL_1]
(
[SETTLENO] [int] NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NULL,
[CASES] [money] NULL,
[QTY] [money] NULL,
[PRICE] [money] NULL,
[TOTAL] [money] NULL,
[TAX] [money] NULL,
[VALIDDATE] [datetime] NULL,
[WRH] [int] NULL,
[INVQTY] [money] NULL,
[ARVQTY] [money] NULL,
[ASNQTY] [money] NULL,
[ALLINVQTY] [money] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FROMGID] [int] NOT NULL,
[FLAG] [int] NOT NULL
) ON [PRIMARY]
GO
