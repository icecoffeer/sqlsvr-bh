CREATE TABLE [dbo].[库存日报表]
(
[日期] [datetime] NULL,
[类别代码] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[商品代码] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[商品名称] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[核算进价] [money] NULL,
[核算售价] [money] NULL,
[数量] [money] NULL,
[进价金额] [money] NULL,
[售价金额] [money] NULL,
[营销方式] [smallint] NOT NULL,
[有问题] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[经销差价] [money] NULL,
[处理幅度] [money] NULL
) ON [PRIMARY]
GO
