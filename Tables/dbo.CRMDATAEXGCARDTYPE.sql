CREATE TABLE [dbo].[CRMDATAEXGCARDTYPE]
(
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDATAEX__CARDT__2364B165] DEFAULT ('0000000000'),
[PARVALUE] [decimal] (24, 2) NULL,
[DISCOUNT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CRMDATAEX__DISCO__2458D59E] DEFAULT (100),
[CARDCOST] [decimal] (24, 4) NULL,
[CARDUSAGE] [smallint] NOT NULL CONSTRAINT [DF__CRMDATAEX__CARDU__254CF9D7] DEFAULT (0),
[MEDIUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MSPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__MSPRC__26411E10] DEFAULT (0),
[MPPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__MPPRC__27354249] DEFAULT (0),
[MCPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__MCPRC__28296682] DEFAULT (0),
[VALIDPRD] [int] NULL,
[ABORTPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__ABORT__291D8ABB] DEFAULT (0),
[RESUMEPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__RESUM__2A11AEF4] DEFAULT (0),
[BACKPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__BACKP__2B05D32D] DEFAULT (0),
[TRANRATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMDATAEX__TRANR__2BF9F766] DEFAULT (0),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDATAEX__CREAT__2CEE1B9F] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CRMDATAEX__CREAT__2DE23FD8] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDATAEX__LSTUP__2ED66411] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMDATAEX__LSTUP__2FCA884A] DEFAULT (getdate()),
[SNDTIME] [datetime] NULL,
[SYSUUID] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDATAEX__SYSUU__30BEAC83] DEFAULT ('-'),
[MBRGENMODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDATAEX__MBRGE__31B2D0BC] DEFAULT ('-'),
[FSENDTIME] [datetime] NOT NULL,
[FSRCORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FDESTORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMDATAEXGCARDTYPE] ADD CONSTRAINT [PK__CRMDATAEXGCARDTY__32A6F4F5] PRIMARY KEY CLUSTERED  ([FSRCORG], [FDESTORG], [FSENDTIME], [CODE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CRMDATAEXGCARDTYPE_FST] ON [dbo].[CRMDATAEXGCARDTYPE] ([FSENDTIME]) ON [PRIMARY]
GO
