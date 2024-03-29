CREATE TABLE [dbo].[PS3_ONLINECNTRDTL]
(
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PLATFORM] [varchar] (80) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CNTRNO] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[CHGCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GENUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[GENCYCLE] [smallint] NULL,
[GENDAYOFFSET] [smallint] NULL,
[AMOUNT] [decimal] (24, 2) NULL,
[GENDATE] [datetime] NULL,
[STORESCOPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3_ONLIN__STORE__6048667D] DEFAULT ('全部'),
[GDSCOPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3_ONLIN__GDSCO__613C8AB6] DEFAULT ('全部'),
[GDSCOPETEXT] [char] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[GATHERINGMODE] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3_ONLIN__GATHE__6230AEEF] DEFAULT ('冲扣货款'),
[PAYDIRECT] [int] NULL CONSTRAINT [DF__PS3_ONLIN__PAYDI__6324D328] DEFAULT ((1)),
[ISADDED] [int] NOT NULL CONSTRAINT [DF__PS3_ONLIN__ISADD__6418F761] DEFAULT ((0)),
[OFFSETCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SINGLEFEE] [int] NOT NULL CONSTRAINT [DF__PS3_ONLIN__SINGL__650D1B9A] DEFAULT ((0)),
[GUARDTYPE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[GUARDAMT] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ONLINECNTRDTL] ADD CONSTRAINT [PK__PS3_ONLI__33AEB8215E601E0B] PRIMARY KEY CLUSTERED  ([UUID], [LINE]) ON [PRIMARY]
GO
