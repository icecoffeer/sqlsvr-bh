CREATE TABLE [dbo].[STORERETAILDTL]
(
[Num] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Cls] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Line] [smallint] NOT NULL,
[Remark] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[Gdgid] [int] NOT NULL,
[QpcGid] [int] NOT NULL,
[GdCode] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TaxRate] [decimal] (24, 4) NOT NULL,
[Qpc] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__STORERETAIL__Qpc__0687B03E] DEFAULT (1),
[QpcStr] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__STORERETA__QpcSt__077BD477] DEFAULT ('1*1'),
[CaseCount] [decimal] (24, 4) NULL,
[BuyerOrderQty] [decimal] (24, 4) NOT NULL,
[SenderWrh] [int] NOT NULL,
[BuyerReturnQty] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__STORERETA__Buyer__086FF8B0] DEFAULT (0),
[BuyerReturnTotal] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__STORERETA__Buyer__09641CE9] DEFAULT (0),
[BuyerRealReturnQty] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__STORERETA__Buyer__0A584122] DEFAULT (0),
[Price] [decimal] (24, 4) NOT NULL,
[RtlPrc] [decimal] (24, 4) NOT NULL,
[InPrc] [decimal] (24, 4) NOT NULL,
[Discount] [decimal] (24, 2) NULL,
[Total] [decimal] (24, 2) NOT NULL,
[Tax] [decimal] (24, 2) NOT NULL,
[FavAmt] [decimal] (24, 2) NULL,
[SellerAssistant] [int] NOT NULL,
[PrmTag] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Cost] [decimal] (24, 2) NULL,
[ReCalcInPrcTag] [smallint] NULL,
[BuyerActionCode] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STORERETAILDTL] ADD CONSTRAINT [PK__StoreRetailDtl__0B4C655B] PRIMARY KEY CLUSTERED  ([Num], [Cls], [Line]) ON [PRIMARY]
GO
