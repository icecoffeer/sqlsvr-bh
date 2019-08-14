CREATE TABLE [dbo].[VOUCHERCASHSPAN]
(
[NUM] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ASTART] [datetime] NOT NULL CONSTRAINT [DF__VOUCHERCA__ASTAR__709A05CD] DEFAULT ('1899.12.30 00:00:00'),
[AFINISH] [datetime] NOT NULL CONSTRAINT [DF__VOUCHERCA__AFINI__718E2A06] DEFAULT ('9999.12.31 23:59:59')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERCASHSPAN] ADD CONSTRAINT [PK__VOUCHERCASHSPAN__72824E3F] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
