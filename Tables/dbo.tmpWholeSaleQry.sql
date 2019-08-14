CREATE TABLE [dbo].[tmpWholeSaleQry]
(
[CLIENT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CLIENTGID] [int] NULL,
[BILLTO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTOGID] [int] NULL,
[WRH] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WRHGID] [int] NULL,
[SLR] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SLRGID] [int] NULL,
[OCRDATE] [datetime] NULL,
[PAYDATE] [datetime] NULL,
[PAYMODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GDCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GDGID] [int] NULL,
[QTY] [money] NULL,
[PRICE] [money] NULL,
[TOTAL] [money] NULL
) ON [PRIMARY]
GO
