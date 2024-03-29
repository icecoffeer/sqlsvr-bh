CREATE TABLE [dbo].[PRMOFFSETDTLDTLTEMP]
(
[spid] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEM] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[AGMNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMOFFSET__AGMNU__6E5D82F7] DEFAULT (''),
[AGMLINE] [int] NULL,
[SAMT] [decimal] (24, 2) NULL,
[RAMT] [decimal] (24, 2) NULL,
[SQTY] [decimal] (24, 4) NULL,
[RQTY] [decimal] (24, 4) NULL,
[AGMTABLENAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMOFFSET__AGMTA__6F51A730] DEFAULT ('PRMOFFSETAGM')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PRMOFFSETDTLDTLTEMP_GDGID] ON [dbo].[PRMOFFSETDTLDTLTEMP] ([spid], [GDGID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PRMOFFSETDTLDTLTEMP_STOREGID] ON [dbo].[PRMOFFSETDTLDTLTEMP] ([spid], [STOREGID]) ON [PRIMARY]
GO
