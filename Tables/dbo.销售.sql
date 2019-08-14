CREATE TABLE [dbo].[销售]
(
[商品代码] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[商品名称] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[核算进价] [float] NULL,
[核算售价] [float] NULL,
[期初数量] [float] NULL,
[期初进价额] [float] NULL,
[期初售价额] [float] NULL,
[备注] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
