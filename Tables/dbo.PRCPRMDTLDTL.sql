CREATE TABLE [dbo].[PRCPRMDTLDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEM] [smallint] NOT NULL,
[SETTLENO] [int] NULL,
[START] [datetime] NULL CONSTRAINT [DF__PRCPRMDTL__START__6E17311D] DEFAULT ('1899.12.30 00:00:00'),
[FINISH] [datetime] NULL CONSTRAINT [DF__PRCPRMDTL__FINIS__6F0B5556] DEFAULT ('9999.12.31 23:59:59'),
[CYCLE] [datetime] NULL CONSTRAINT [DF__PRCPRMDTL__CYCLE__6FFF798F] DEFAULT ('1899.12.30 00:00:00'),
[CSTART] [datetime] NULL CONSTRAINT [DF__PRCPRMDTL__CSTAR__70F39DC8] DEFAULT ('1899.12.30 00:00:00'),
[CFINISH] [datetime] NULL CONSTRAINT [DF__PRCPRMDTL__CFINI__71E7C201] DEFAULT ('9999.12.31 23:59:59'),
[CSPEC] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[QTYLO] [money] NULL CONSTRAINT [DF__PRCPRMDTL__QTYLO__72DBE63A] DEFAULT (0),
[QTYHI] [money] NULL CONSTRAINT [DF__PRCPRMDTL__QTYHI__73D00A73] DEFAULT (99999999),
[PRICE] [money] NULL,
[DISCOUNT] [decimal] (5, 2) NULL,
[GFTGID] [int] NULL,
[GFTQTY] [money] NULL,
[GFTPER] [money] NULL,
[GFTTYPE] [smallint] NULL,
[INPRC] [money] NULL,
[PrmTag] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[MBRPRC] [money] NULL,
[PRMLWTPRC] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCPRMDTLDTL] ADD CONSTRAINT [PK__PRCPRMDTLDTL__789EE131] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [ITEM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
