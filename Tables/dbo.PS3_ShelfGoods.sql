CREATE TABLE [dbo].[PS3_ShelfGoods]
(
[shelfId] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gdCode] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gdBarCode] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[createTime] [datetime] NOT NULL CONSTRAINT [DF__PS3_Shelf__creat__6A06DAE1] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ShelfGoods] ADD CONSTRAINT [PK__PS3_Shel__6CC2ED566BEF2353] PRIMARY KEY CLUSTERED  ([shelfId], [gdCode]) ON [PRIMARY]
GO
