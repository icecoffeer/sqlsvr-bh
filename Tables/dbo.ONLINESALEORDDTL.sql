CREATE TABLE [dbo].[ONLINESALEORDDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDCODE] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__ONLINESALEO__QTY__6B3A2AE5] DEFAULT (0),
[REALPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__ONLINESAL__REALP__6C2E4F1E] DEFAULT (0),
[REALAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ONLINESAL__REALA__6D227357] DEFAULT (0),
[PRICE] [decimal] (24, 2) NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[SCORE] [decimal] (24, 4) NULL CONSTRAINT [DF__ONLINESAL__SCORE__6E169790] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ONLINESALEORDDTL] ADD CONSTRAINT [PK__OnlineSaleOrdDtl__6F0ABBC9] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
