CREATE TABLE [dbo].[Q_DC_PRN]
(
[GRPID] [decimal] (24, 2) NULL,
[LINE] [decimal] (24, 2) NULL,
[SLOT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[GDCODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[GDNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[MUNIT] [varchar] (6) COLLATE Chinese_PRC_CI_AS NULL,
[SPEC] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[QTY] [decimal] (24, 4) NULL,
[QTYSTR] [decimal] (24, 4) NULL,
[FILDATE] [datetime] NULL,
[SCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [decimal] (24, 2) NULL,
[STORECODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[ALCREASON] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ACODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
