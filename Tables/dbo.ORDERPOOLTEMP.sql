CREATE TABLE [dbo].[ORDERPOOLTEMP]
(
[spid] [int] NOT NULL,
[GDGID] [int] NULL,
[VDRGID] [int] NULL,
[WRH] [int] NULL,
[COMBINETYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SENDDATE] [datetime] NULL,
[QTY] [decimal] (24, 4) NULL,
[PRICE] [decimal] (24, 4) NULL,
[SPLITDAYS] [int] NULL,
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STOREORDAPPLYTYPE] [int] NULL,
[STOREORDAPPLYSTAT] [int] NULL
) ON [PRIMARY]
GO
