CREATE TABLE [dbo].[奖金发放]
(
[settleno] [int] NULL,
[gid] [int] NULL,
[员工] [char] (12) COLLATE Chinese_PRC_CI_AS NULL,
[姓名] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[部门] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[销售笔数] [money] NULL CONSTRAINT [DF__奖金发放__销售笔数__2FD0B138] DEFAULT (0),
[销售额] [money] NULL CONSTRAINT [DF__奖金发放__销售额__30C4D571] DEFAULT (0),
[奖金] [money] NULL CONSTRAINT [DF__奖金发放__奖金__31B8F9AA] DEFAULT (0),
[定额] [money] NULL CONSTRAINT [DF__奖金发放__定额__32AD1DE3] DEFAULT (0),
[工资底] [money] NULL CONSTRAINT [DF__奖金发放__工资底__33A1421C] DEFAULT (0),
[类型] [char] (6) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__奖金发放__类型__34956655] DEFAULT ('营业员')
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [jjff_stl] ON [dbo].[奖金发放] ([settleno], [部门], [员工], [类型]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
