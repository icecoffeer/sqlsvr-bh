CREATE TABLE [dbo].[tmp_ckdtl]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[SETTLENO] [int] NULL,
[GDGID] [int] NULL,
[WRH] [int] NULL,
[ACNTQTY] [money] NULL,
[QTY] [money] NULL,
[ACNTTL] [money] NULL,
[TOTAL] [money] NULL,
[OVFAMT] [money] NULL,
[LOSAMT] [money] NULL,
[INPRC] [money] NULL,
[RTLPRC] [money] NULL,
[ACNTQTY2] [money] NULL,
[ACNTTL2] [money] NULL,
[INPRC2] [money] NULL,
[RTLPRC2] [money] NULL,
[subwrh] [int] NULL,
[COST] [money] NOT NULL
) ON [PRIMARY]
GO
