CREATE TABLE [dbo].[NSTKINDTL2]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__NSTKINDTL2__QTY__4614F812] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__NSTKINDTL2__COST__47091C4B] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTKINDTL2] ADD CONSTRAINT [PK__NSTKINDTL2__4520D3D9] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [SUBWRH]) ON [PRIMARY]
GO
