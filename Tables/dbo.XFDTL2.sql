CREATE TABLE [dbo].[XFDTL2]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[FROMTO] [smallint] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__XFDTL2__QTY__415042F5] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__XFDTL2__COST__4244672E] DEFAULT (0),
[COSTADJ] [money] NOT NULL CONSTRAINT [DF__XFDTL2__COSTADJ__43388B67] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XFDTL2] ADD CONSTRAINT [PK__XFDTL2__405C1EBC] PRIMARY KEY CLUSTERED  ([SUBWRH], [NUM], [LINE], [FROMTO]) ON [PRIMARY]
GO
