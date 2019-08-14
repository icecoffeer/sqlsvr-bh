CREATE TABLE [dbo].[Q_DC_STRCVGD]
(
[FNO] [decimal] (24, 2) NULL,
[QTY] [decimal] (24, 2) NULL,
[ZQTY] [decimal] (24, 4) NULL,
[FILDATE] [datetime] NULL,
[SCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [decimal] (24, 2) NULL,
[STORECODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STORENAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ALCREASON] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ACODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
