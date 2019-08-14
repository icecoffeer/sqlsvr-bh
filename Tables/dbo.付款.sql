CREATE TABLE [dbo].[付款]
(
[供应商代码] [char] (8) COLLATE Chinese_PRC_CI_AS NULL,
[已销进价额] [money] NULL,
[代销已销额] [float] NULL,
[供应商代码1] [char] (8) COLLATE Chinese_PRC_CI_AS NULL,
[销售进价额] [money] NULL,
[净销售额] [float] NULL,
[已结进价额] [money] NULL,
[已结销售额] [float] NULL,
[剩余数量] [float] NULL,
[剩余进价额] [float] NULL,
[剩余销售额] [float] NULL,
[应付进价额] [money] NULL,
[应付销售额] [float] NULL,
[sort] [char] (5) COLLATE Chinese_PRC_CI_AS NULL,
[gid] [int] NULL
) ON [PRIMARY]
GO
