CREATE TABLE [dbo].[商品库存表]
(
[adate] [datetime] NOT NULL,
[gdgid] [int] NOT NULL,
[qtyIn] [money] NOT NULL CONSTRAINT [DF__商品库存表__qtyIn__2DFE42B6] DEFAULT (0),
[qtyOut] [money] NOT NULL CONSTRAINT [DF__商品库存表__qtyOut__2EF266EF] DEFAULT (0),
[qtyPay] [money] NOT NULL CONSTRAINT [DF__商品库存表__qtyPay__2FE68B28] DEFAULT (0),
[qty11] [money] NOT NULL CONSTRAINT [DF__商品库存表__qty11__30DAAF61] DEFAULT (0),
[qty12] [money] NOT NULL CONSTRAINT [DF__商品库存表__qty12__31CED39A] DEFAULT (0),
[qty21] [money] NOT NULL CONSTRAINT [DF__商品库存表__qty21__32C2F7D3] DEFAULT (0),
[qty22] [money] NOT NULL CONSTRAINT [DF__商品库存表__qty22__33B71C0C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[商品库存表] ADD CONSTRAINT [PK__商品库存表__4AA30C57] PRIMARY KEY CLUSTERED  ([adate], [gdgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
