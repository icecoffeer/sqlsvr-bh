CREATE TABLE [dbo].[ORDERPOOLH]
(
[UUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[VDRGID] [int] NOT NULL,
[WRH] [int] NOT NULL,
[COMBINETYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SENDDATE] [datetime] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[PRICE] [decimal] (24, 4) NULL,
[ORDERTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[IMPTIME] [datetime] NOT NULL,
[IMPORTER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDERDATE] [datetime] NOT NULL,
[SPLITDAYS] [smallint] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STOREORDAPPLYTYPE] [int] NULL,
[STOREORDAPPLYSTAT] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDERPOOLH] ADD CONSTRAINT [PK__ORDERPOOLH__7D580FC9] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ORDERPOOLH_DIMENSION] ON [dbo].[ORDERPOOLH] ([VDRGID], [WRH], [COMBINETYPE], [SENDDATE], [GDGID]) ON [PRIMARY]
GO
