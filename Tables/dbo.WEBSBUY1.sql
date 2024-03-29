CREATE TABLE [dbo].[WEBSBUY1]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SHOPCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSID] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SALEDATE] [datetime] NOT NULL,
[BACKDATE] [datetime] NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[AMOUNT] [decimal] (24, 4) NOT NULL,
[SCORE] [decimal] (24, 4) NULL,
[CARDNO] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CASHIERCODE] [char] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ASSISTANTCODE] [char] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TAG] [smallint] NOT NULL,
[TAGLOG] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WEBSBUY1] ADD CONSTRAINT [PK__WEBSBUY1__2960AF39] PRIMARY KEY CLUSTERED  ([SHOPCODE], [FLOWNO], [POSID]) ON [PRIMARY]
GO
