CREATE TABLE [dbo].[BUY2POOL]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[GID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY2POOL__QTY__5EC4A2FE] DEFAULT (0),
[INPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY2POOL__INPRC__5FB8C737] DEFAULT (0),
[PRICE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY2POOL__PRICE__60ACEB70] DEFAULT (0),
[REALAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY2POOL__REALAM__61A10FA9] DEFAULT (0),
[FAVAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY2POOL__FAVAMT__629533E2] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__BUY2POOL__TAG__6389581B] DEFAULT (0),
[QPCGID] [int] NULL,
[PRMTAG] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ASSISTANT] [int] NULL,
[WRH] [int] NULL CONSTRAINT [DF__BUY2POOL__WRH__647D7C54] DEFAULT (1),
[INVNO] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[COST] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY2POOL__COST__6571A08D] DEFAULT (0),
[DEALER] [int] NULL,
[IQTY] [decimal] (24, 2) NULL,
[GDCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUY2POOL] ADD CONSTRAINT [PK__BUY2POOL__6665C4C6] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO], [ITEMNO]) ON [PRIMARY]
GO