CREATE TABLE [dbo].[奖金发放鞋帽]
(
[settleno] [int] NULL,
[gid] [int] NULL,
[员工] [char] (12) COLLATE Chinese_PRC_CI_AS NULL,
[姓名] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[部门] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[销售笔数] [money] NULL,
[销售额] [money] NULL,
[奖金] [money] NULL,
[定额] [money] NULL,
[工资底] [money] NULL,
[类型] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[计划] [money] NULL,
[提奖系数] [money] NULL
) ON [PRIMARY]
GO
