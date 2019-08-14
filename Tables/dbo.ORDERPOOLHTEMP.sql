CREATE TABLE [dbo].[ORDERPOOLHTEMP]
(
[spid] [int] NOT NULL,
[UUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[GDGID] [int] NULL,
[VDRGID] [int] NULL,
[WRH] [int] NULL,
[COMBINETYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SENDDATE] [datetime] NULL,
[QTY] [decimal] (24, 4) NULL,
[PRICE] [decimal] (24, 4) NULL,
[ORDERTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[IMPTIME] [datetime] NULL,
[IMPORTER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[ORDERDATE] [datetime] NULL,
[SPLITDAYS] [smallint] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STOREORDAPPLYTYPE] [int] NULL,
[STOREORDAPPLYSTAT] [int] NULL
) ON [PRIMARY]
GO
