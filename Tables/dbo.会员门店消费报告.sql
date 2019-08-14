CREATE TABLE [dbo].[会员门店消费报告]
(
[门店] [int] NOT NULL,
[会员] [int] NOT NULL,
[消费总额] [money] NOT NULL CONSTRAINT [DF__会员门店消费报告__消费总额__3EA8E074] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[会员门店消费报告] ADD CONSTRAINT [PK__会员门店消费报告__48BAC3E5] PRIMARY KEY CLUSTERED  ([会员], [门店]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
