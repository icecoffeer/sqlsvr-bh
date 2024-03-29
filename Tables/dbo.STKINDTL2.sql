CREATE TABLE [dbo].[STKINDTL2]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__STKINDTL2__CLS__1571C0B7] DEFAULT ('自营'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__STKINDTL2__QTY__1665E4F0] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__STKINDTL2__COST__175A0929] DEFAULT (0),
[COSTADJ] [money] NOT NULL CONSTRAINT [DF__STKINDTL2__COSTA__184E2D62] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STKINDTL2] ADD CONSTRAINT [PK__STKINDTL2__147D9C7E] PRIMARY KEY CLUSTERED  ([SUBWRH], [CLS], [NUM], [LINE]) ON [PRIMARY]
GO
