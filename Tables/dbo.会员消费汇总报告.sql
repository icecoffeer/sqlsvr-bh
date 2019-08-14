CREATE TABLE [dbo].[会员消费汇总报告]
(
[会员] [int] NOT NULL,
[消费总额] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[会员消费汇总报告] ADD CONSTRAINT [PK__会员消费汇总报告__49AEE81E] PRIMARY KEY CLUSTERED  ([会员]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
