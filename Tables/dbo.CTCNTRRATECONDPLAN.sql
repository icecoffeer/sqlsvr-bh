CREATE TABLE [dbo].[CTCNTRRATECONDPLAN]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[VENDOR] [int] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[EXPAMT] [decimal] (24, 2) NOT NULL,
[ADDRATE] [decimal] (24, 2) NOT NULL,
[EXESTAT] [int] NOT NULL,
[EXEBILLINFO] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRRATECONDPLAN] ADD CONSTRAINT [PK__CTCNTRRATECONDPL__65A7760E] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE]) ON [PRIMARY]
GO
