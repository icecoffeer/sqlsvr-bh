CREATE TABLE [dbo].[PS3_ONLINEORDGOODS]
(
[PLATFORM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDNO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[GDCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[PRICE] [decimal] (24, 2) NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[REALAMOUNT] [decimal] (24, 2) NOT NULL,
[SRCITEMNO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SINGLEPRICE] [decimal] (24, 2) NULL,
[SETTLEPRICE] [decimal] (24, 2) NULL,
[SETTLETOTAL] [decimal] (24, 2) NULL,
[SCORE] [decimal] (24, 2) NULL,
[HASDTL] [smallint] NULL CONSTRAINT [DF__PS3_ONLIN__HASDT__581D34D0] DEFAULT ((0)),
[SHOPPRICE] [decimal] (24, 4) NULL,
[SHOPTOTAL] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ONLINEORDGOODS] ADD CONSTRAINT [PK__PS3_OnLineOrdGoo__04F9FCE8] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO]) ON [PRIMARY]
GO