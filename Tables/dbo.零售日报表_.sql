CREATE TABLE [dbo].[零售日报表_]
(
[日期] [datetime] NULL,
[商品] [int] NULL,
[零售数] [money] NULL,
[零售退货数] [money] NULL,
[零售额] [money] NULL,
[零售退货额] [money] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [零售日报表_GID] ON [dbo].[零售日报表_] ([日期], [商品]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
