CREATE TABLE [dbo].[CQNSTKINDTL2]
(
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNSTKIND__NSTAT__053DBAF3] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNSTKIND__EXTIM__0631DF2C] DEFAULT (getdate()),
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CQNSTKINDTL__CLS__07260365] DEFAULT ('自营'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNSTKINDTL__QTY__081A279E] DEFAULT (0),
[COST] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNSTKINDT__COST__090E4BD7] DEFAULT (0),
[COSTADJ] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNSTKIND__COSTA__0A027010] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNSTKINDTL2] ADD CONSTRAINT [PK__CQNSTKINDTL2__0AF69449] PRIMARY KEY CLUSTERED  ([GROUPID], [CLS], [NUM], [LINE], [SUBWRH]) ON [PRIMARY]
GO
