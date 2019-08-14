CREATE TABLE [dbo].[NPURCHASEORDER]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[VENDOR] [int] NOT NULL CONSTRAINT [DF__NPURCHASE__VENDO__7C8944B8] DEFAULT (1),
[TOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__TOTAL__7D7D68F1] DEFAULT (0),
[TAX] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASEOR__TAX__7E718D2A] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NPURCHASE__FILDA__7F65B163] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__NPURCHASE__FILLE__0059D59C] DEFAULT (1),
[CHECKER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NPURCHASEO__STAT__014DF9D5] DEFAULT (0),
[WRH] [int] NOT NULL CONSTRAINT [DF__NPURCHASEOR__WRH__02421E0E] DEFAULT (1),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NPURCHASE__RECCN__03364247] DEFAULT (0),
[SRC] [int] NOT NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[RECEIVER] [int] NOT NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__NPURCHASEOR__PSR__042A6680] DEFAULT (1),
[PRNTIME] [datetime] NULL,
[PRECHECKER] [int] NULL,
[PRECHKDATE] [datetime] NULL,
[DEPT] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[CUSTOMIZETYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RCVTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SELLERAPPROVEOPERATOR] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SELLERREFNUMBER] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SELLERAPPROVETIME] [datetime] NULL,
[SELLERREMARK] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERNAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERREFNUMBER] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERADDRESS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERTELEPHONE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERORDERTIME] [datetime] NULL,
[BUYERORDEREXPIRATIONDATE] [datetime] NULL,
[BUYERORDERTYPE] [int] NOT NULL,
[BUYERFILDATE] [datetime] NULL,
[BUYERSELLOPERATOR] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BUYERCUSTMIZEDIMAGE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERINVOICENUMBER] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SUPPLIERCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SUPPLIERNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NPURCHASE__LSTUP__051E8AB9] DEFAULT (getdate()),
[ID] [int] NOT NULL,
[NSTAT] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[CONFIRMDATE] [datetime] NULL,
[CONFIRMER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CUSTOMIZEMEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BCKCAUSE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FINISHED] [smallint] NOT NULL CONSTRAINT [DF__NPURCHASE__FINIS__0612AEF2] DEFAULT (0),
[NearBy] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[LANE] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[BUILDING] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ROOM] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BUYERREGIONDTL] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[RTLTOTAL] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__RTLTO__0706D32B] DEFAULT (0),
[ORDAMT] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__ORDAM__07FAF764] DEFAULT (0),
[SUPPLIERORDERTIME] [datetime] NULL,
[INPRCAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__INPRC__08EF1B9D] DEFAULT (0),
[SELLERCONINFO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FINISHEDDATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPURCHASEORDER] ADD CONSTRAINT [PK__NPURCHASEORDER__09E33FD6] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO
