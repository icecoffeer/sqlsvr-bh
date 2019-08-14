CREATE TABLE [dbo].[icbuybck]
(
[flowno] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[posno] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[itemno] [smallint] NOT NULL,
[currency] [smallint] NOT NULL,
[amount] [money] NOT NULL CONSTRAINT [DF__icbuybck__amount__4C77DCDE] DEFAULT (0),
[cardcode] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BCKAMT] [money] NOT NULL CONSTRAINT [DF__icbuybck__BCKAMT__4D6C0117] DEFAULT (0),
[BCKTIME] [datetime] NOT NULL CONSTRAINT [DF__icbuybck__BCKTIM__4E602550] DEFAULT (getdate()),
[FILLER] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ICBUYBCK] ON [dbo].[icbuybck] ([flowno], [posno], [itemno], [currency]) ON [PRIMARY]
GO
