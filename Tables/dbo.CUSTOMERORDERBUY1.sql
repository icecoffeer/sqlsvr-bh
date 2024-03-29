CREATE TABLE [dbo].[CUSTOMERORDERBUY1]
(
[FLOWNO] [char] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__CUSTOMERO__FILDA__1C50CCDE] DEFAULT (getdate()),
[CASHIER] [int] NOT NULL CONSTRAINT [DF__CUSTOMERO__CASHI__1D44F117] DEFAULT (1),
[WRH] [int] NOT NULL CONSTRAINT [DF__CUSTOMERORD__WRH__1E391550] DEFAULT (1),
[ASSISTANT] [int] NULL,
[TOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CUSTOMERO__TOTAL__1F2D3989] DEFAULT (0),
[REALAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CUSTOMERO__REALA__20215DC2] DEFAULT (0),
[PREVAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CUSTOMERO__PREVA__211581FB] DEFAULT (0),
[GUEST] [int] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__CUSTOMERO__RECCN__2209A634] DEFAULT (0),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SENT] [varchar] (1) COLLATE Chinese_PRC_CI_AS NULL,
[ScrTotal] [decimal] (24, 4) NULL,
[ScrFavMode] [int] NOT NULL,
[scrFavValue] [decimal] (24, 4) NULL,
[TAG] [smallint] NOT NULL CONSTRAINT [DF__CUSTOMERORD__TAG__22FDCA6D] DEFAULT (0),
[INVNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SCORE] [decimal] (24, 4) NULL,
[CARDCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[DEALER] [int] NULL,
[FLAG] [int] NOT NULL CONSTRAINT [DF__CUSTOMEROR__FLAG__23F1EEA6] DEFAULT (0),
[RFNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SCOREINFO] [char] (256) COLLATE Chinese_PRC_CI_AS NULL,
[ScorePrnBuf] [char] (256) COLLATE Chinese_PRC_CI_AS NULL,
[OrderState] [int] NOT NULL CONSTRAINT [DF__CUSTOMERO__Order__24E612DF] DEFAULT (1),
[OrderCreateTime] [datetime] NOT NULL CONSTRAINT [DF__CUSTOMERO__Order__25DA3718] DEFAULT (getdate()),
[OrderFinishTime] [datetime] NOT NULL CONSTRAINT [DF__CUSTOMERO__Order__26CE5B51] DEFAULT (getdate()),
[OrderCancelTime] [datetime] NOT NULL CONSTRAINT [DF__CUSTOMERO__Order__27C27F8A] DEFAULT (getdate()),
[CancelCASHIER] [int] NULL,
[OrderUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OrderAmt] [decimal] (24, 4) NULL,
[UnPayAmt] [decimal] (24, 4) NULL,
[BuyPOSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BuyFLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CUSTOMERORDERBUY1] ADD CONSTRAINT [PK__CustomerOrderBUY__28B6A3C3] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[CUSTOMERORDERBUY1] ([FILDATE]) ON [PRIMARY]
GO
