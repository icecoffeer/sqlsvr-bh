CREATE TABLE [dbo].[t_code1]
(
[商品代码] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[柜台库存] [decimal] (11, 2) NULL,
[仓库库存] [decimal] (9, 2) NULL
) ON [PRIMARY]
GO
