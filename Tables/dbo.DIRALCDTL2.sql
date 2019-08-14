CREATE TABLE [dbo].[DIRALCDTL2]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DIRALCDTL2__CLS__2A6CDD9D] DEFAULT ('直配'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__DIRALCDTL2__QTY__2B6101D6] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__DIRALCDTL2__COST__2C55260F] DEFAULT (0),
[COSTADJ] [money] NOT NULL CONSTRAINT [DF__DIRALCDTL__COSTA__2D494A48] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIRALCDTL2] ADD CONSTRAINT [PK__DIRALCDTL2__2978B964] PRIMARY KEY CLUSTERED  ([SUBWRH], [CLS], [NUM], [LINE]) ON [PRIMARY]
GO