CREATE TABLE [dbo].[PS3_ONLINERETURNORDGOODS]
(
[PLATFORM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDNO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[GDCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDNAME] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[PRICE] [decimal] (24, 2) NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[REFUNDAMOUNT] [decimal] (24, 2) NOT NULL,
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLEPRICE] [decimal] (24, 2) NULL,
[SETTLETOTAL] [decimal] (24, 2) NULL,
[HASDTL] [smallint] NULL CONSTRAINT [DF__PS3_ONLIN__HASDT__59115909] DEFAULT ((0)),
[SHOPPRICE] [decimal] (24, 4) NULL,
[SHOPTOTAL] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ONLINERETURNORDGOODS] ADD CONSTRAINT [PK__PS3_OnLineReturn__180CD15C] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO]) ON [PRIMARY]
GO