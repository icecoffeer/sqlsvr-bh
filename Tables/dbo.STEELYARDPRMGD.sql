CREATE TABLE [dbo].[STEELYARDPRMGD]
(
[GDGID] [int] NOT NULL,
[START] [datetime] NULL,
[FINISH] [datetime] NULL,
[CYCLE] [datetime] NULL,
[CSTART] [datetime] NULL,
[CFINISH] [datetime] NULL,
[QTYLO] [decimal] (24, 4) NULL,
[QTYHI] [decimal] (24, 4) NULL,
[PRICE] [decimal] (24, 4) NULL,
[STOREGID] [int] NOT NULL,
[SENDFLAG] [int] NULL,
[CURTIME] [datetime] NULL
) ON [PRIMARY]
GO
