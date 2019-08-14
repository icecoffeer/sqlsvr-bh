CREATE TABLE [dbo].[会员奖励发放记录]
(
[日期] [datetime] NOT NULL,
[会员] [int] NOT NULL,
[可奖励的消费额] [money] NOT NULL,
[奖励金额] [money] NOT NULL,
[备注] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[会员奖励发放记录] ADD CONSTRAINT [PK__会员奖励发放记录__47C69FAC] PRIMARY KEY CLUSTERED  ([会员], [日期]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
