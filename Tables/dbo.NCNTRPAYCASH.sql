CREATE TABLE [dbo].[NCNTRPAYCASH]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NCNTRPAYC__FILDA__1217C7CD] DEFAULT (getdate()),
[VDRGID] [int] NOT NULL,
[TRANSACTOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [smallint] NOT NULL,
[PRNTIME] [datetime] NULL,
[PAYTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__PAYTO__130BEC06] DEFAULT (0),
[SALETOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__SALET__1400103F] DEFAULT (0),
[FEETOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__FEETO__14F43478] DEFAULT (0),
[PREPAYTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__PREPA__15E858B1] DEFAULT (0),
[SETTLEACCOUNTNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NCNTRPAYC__LSTUP__16DC7CEA] DEFAULT (getdate()),
[PLANDATE] [datetime] NULL,
[FROMDATE] [datetime] NULL,
[TODATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKFLAG] [smallint] NOT NULL CONSTRAINT [DF__NCNTRPAYC__CHKFL__17D0A123] DEFAULT (0),
[PSR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCNTRPAYCAS__PSR__18C4C55C] DEFAULT (1),
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[I_INV_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__I_INV__19B8E995] DEFAULT (0),
[F_INV_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__F_INV__1AAD0DCE] DEFAULT (0),
[SUM_IN_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__SUM_I__1BA13207] DEFAULT (0),
[SUM_OUT_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__SUM_O__1C955640] DEFAULT (0),
[SUM_PAY_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__SUM_P__1D897A79] DEFAULT (0),
[I_OS_BAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__I_OS___1E7D9EB2] DEFAULT (0),
[F_OS_BAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__F_OS___1F71C2EB] DEFAULT (0),
[IN_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__IN_AM__2065E724] DEFAULT (0),
[OUT_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__OUT_A__215A0B5D] DEFAULT (0),
[OUT_COST] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__OUT_C__224E2F96] DEFAULT (0),
[SH_SALE_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__SH_SA__234253CF] DEFAULT (0),
[SH_FEE_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__SH_FE__24367808] DEFAULT (0),
[PREPAY_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__PREPA__252A9C41] DEFAULT (0),
[PAYED_AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCNTRPAYC__PAYED__261EC07A] DEFAULT (0),
[CYCLE] [int] NOT NULL CONSTRAINT [DF__NCNTRPAYC__CYCLE__2712E4B3] DEFAULT (0),
[BTYPE] [int] NOT NULL CONSTRAINT [DF__NCNTRPAYC__BTYPE__280708EC] DEFAULT (0),
[BALUNIT] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NOT NULL,
[SENDCOUNT] [smallint] NOT NULL CONSTRAINT [DF__NCNTRPAYC__SENDC__28FB2D25] DEFAULT (0),
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCNTRPAYCAS__CLS__29EF515E] DEFAULT ('付款'),
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[FRCCHK] [smallint] NOT NULL CONSTRAINT [DF__NCNTRPAYC__FRCCH__2AE37597] DEFAULT (0),
[GROUPID] [int] NOT NULL,
[NO] [smallint] NOT NULL,
[MODNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCNTRPAYCASH] ADD CONSTRAINT [PK__NCNTRPAYCASH__2BD799D0] PRIMARY KEY CLUSTERED  ([SRC], [GROUPID], [NO]) ON [PRIMARY]
GO
