CREATE TABLE [dbo].[ORDDTL]
(
[SETTLENO] [int] NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NULL,
[CASES] [money] NULL,
[QTY] [money] NULL,
[PRICE] [money] NULL,
[TOTAL] [money] NULL,
[TAX] [money] NULL,
[VALIDDATE] [datetime] NULL,
[WRH] [int] NULL CONSTRAINT [DF__ORDDTL__WRH__5A9A4855] DEFAULT (1),
[INVQTY] [money] NULL CONSTRAINT [DF__ORDDTL__INVQTY__5B8E6C8E] DEFAULT (0),
[ARVQTY] [money] NULL CONSTRAINT [DF__ORDDTL__ARVQTY__5C8290C7] DEFAULT (0),
[ASNQTY] [money] NULL CONSTRAINT [DF__ORDDTL__ASNQTY__5D76B500] DEFAULT (0),
[ALLINVQTY] [money] NULL CONSTRAINT [DF__ORDDTL__ALLINVQT__5E6AD939] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FROMGID] [int] NOT NULL CONSTRAINT [DF__orddtl__FROMGID__182344D9] DEFAULT (1),
[FLAG] [int] NOT NULL CONSTRAINT [DF__orddtl__FLAG__19176912] DEFAULT (0),
[INUSE] [smallint] NOT NULL CONSTRAINT [DF__ORDDTL__INUSE__28AF7DB4] DEFAULT (0),
[LOCKNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LOCKCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[subwrh] [int] NULL,
[ADVQTY] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDDTL] ADD CONSTRAINT [PK__ORDDTL__592635D8] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [orddtl_gdgid] ON [dbo].[ORDDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDDTL] ADD CONSTRAINT [在定货单中商品赠品不能重复] UNIQUE NONCLUSTERED  ([NUM], [GDGID], [FROMGID], [FLAG]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
