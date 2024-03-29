CREATE TABLE [dbo].[PRMOFFSETDTLDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEM] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[AGMNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMOFFSET__AGMNU__2E580C7B] DEFAULT (''),
[AGMLINE] [int] NULL,
[SAMT] [decimal] (24, 2) NULL,
[RAMT] [decimal] (24, 2) NULL,
[SQTY] [decimal] (24, 4) NULL,
[RQTY] [decimal] (24, 4) NULL,
[AGMTABLENAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMOFFSET__AGMTA__2F4C30B4] DEFAULT ('PRMOFFSETAGM')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PrmOffSetDtlDtl_GdGid] ON [dbo].[PRMOFFSETDTLDTL] ([GDGID]) ON [PRIMARY]
GO
