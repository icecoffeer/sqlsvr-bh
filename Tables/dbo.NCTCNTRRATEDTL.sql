CREATE TABLE [dbo].[NCTCNTRRATEDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[FEEUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[FEECYCLE] [smallint] NULL,
[FEEDAYOFFSET] [smallint] NULL,
[FSTFEEDATE] [datetime] NULL,
[NEXTBEGINDATE] [datetime] NULL,
[NEXTENDDATE] [datetime] NULL,
[FIXCOST] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCNTRRA__FIXCO__2C0F05FF] DEFAULT (0),
[RATEMODE] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCNTRRA__RATEM__2D032A38] DEFAULT ('数值分段'),
[CALCMODE] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCNTRRA__CALCM__2DF74E71] DEFAULT ('合计'),
[FEEPREC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCNTRRA__FEEPR__2EEB72AA] DEFAULT (0.01),
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCNTRRA__ROUND__2FDF96E3] DEFAULT ('四舍五入'),
[STORESCOPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCNTRRA__STORE__30D3BB1C] DEFAULT ('全部'),
[GDSCOPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCNTRRA__GDSCO__31C7DF55] DEFAULT ('全部'),
[GDSCOPESQL] [char] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[GDSCOPETEXT] [char] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[AHEADDAYS] [int] NOT NULL CONSTRAINT [DF__NCTCNTRRA__AHEAD__32BC038E] DEFAULT (0),
[DISCOUNTRATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCNTRRA__DISCO__33B027C7] DEFAULT (0),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRRATEDTL] ADD CONSTRAINT [PK__NCTCNTRRATEDTL__34A44C00] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
