CREATE TABLE [dbo].[CRMCARDTYPE]
(
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDTY__CARDT__6A2C3409] DEFAULT ('0000000000'),
[DISCOUNT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CRMCARDTY__DISCO__6B205842] DEFAULT (100),
[PARVALUE] [decimal] (24, 2) NULL,
[CARDCOST] [decimal] (24, 4) NULL,
[CARDUSAGE] [smallint] NOT NULL CONSTRAINT [DF__CRMCARDTY__CARDU__6C147C7B] DEFAULT (0),
[MEDIUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MSPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__MSPRC__6D08A0B4] DEFAULT (0),
[MPPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__MPPRC__6DFCC4ED] DEFAULT (0),
[MCPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__MCPRC__6EF0E926] DEFAULT (0),
[VALIDPRD] [int] NULL,
[ABORTPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__ABORT__6FE50D5F] DEFAULT (0),
[BACKPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__BACKP__70D93198] DEFAULT (0),
[RESUMEPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__RESUM__71CD55D1] DEFAULT (0),
[TRANRATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__TRANR__72C17A0A] DEFAULT (0),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDTY__CREAT__73B59E43] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CRMCARDTY__CREAT__74A9C27C] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDTY__LSTUP__759DE6B5] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMCARDTY__LSTUP__76920AEE] DEFAULT (getdate()),
[SNDTIME] [datetime] NULL,
[SYSUUID] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MBRGENMODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDTY__MBRGE__77862F27] DEFAULT ('-'),
[MINBAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDTY__MINBA__787A5360] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMCARDTYPE] ADD CONSTRAINT [PK__CRMCARDTYPE__796E7799] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CRMCARDTYPE_LST] ON [dbo].[CRMCARDTYPE] ([LSTUPDTIME]) ON [PRIMARY]
GO