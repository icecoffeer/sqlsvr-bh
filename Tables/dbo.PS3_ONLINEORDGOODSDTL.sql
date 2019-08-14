CREATE TABLE [dbo].[PS3_ONLINEORDGOODSDTL]
(
[PLATFORM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDNO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[GDCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[RATIO] [decimal] (24, 4) NOT NULL,
[PRICE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3_ONLIN__PRICE__5AF9A17B] DEFAULT ((0)),
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3_ONLIN__TOTAL__5BEDC5B4] DEFAULT ((0)),
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ONLINEORDGOODSDTL] ADD CONSTRAINT [PK__PS3_ONLI__87A446EF5DD60E26] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO], [GDCODE]) ON [PRIMARY]
GO