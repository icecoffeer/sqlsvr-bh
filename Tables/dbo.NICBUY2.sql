CREATE TABLE [dbo].[NICBUY2]
(
[STORE] [int] NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[GID] [int] NOT NULL,
[QTY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY2__QTY__4F937554] DEFAULT (0),
[INPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY2__INPRC__5087998D] DEFAULT (0),
[PRICE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY2__PRICE__517BBDC6] DEFAULT (0),
[REALAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY2__REALAMT__526FE1FF] DEFAULT (0),
[FAVAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY2__FAVAMT__53640638] DEFAULT (0),
[PRMTAG] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ASSISTANT] [int] NULL,
[WRH] [int] NULL CONSTRAINT [DF__NICBUY2__WRH__54582A71] DEFAULT (1),
[INVNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NICBUY2] ADD CONSTRAINT [PK__NICBUY2__4E9F511B] PRIMARY KEY CLUSTERED  ([SRC], [ID], [ITEMNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
