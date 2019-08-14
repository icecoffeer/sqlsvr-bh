CREATE TABLE [dbo].[PS3_OUTEROUTGOODS]
(
[ITEMNO] [int] NOT NULL,
[BILLTO] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PS3_OUTEROU__QTY__5535DB2D] DEFAULT ((1)),
[PRICE] [decimal] (24, 2) NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL,
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_OUTEROUTGOODS] ADD CONSTRAINT [PK__PS3_OUTE__720CA32A571E239F] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO]) ON [PRIMARY]
GO