CREATE TABLE [dbo].[NMXFDMDDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[CONFIRM] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMXFDMDDTL__QTY__7199E255] DEFAULT (0),
[FROMPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMXFDMDDT__FROMP__728E068E] DEFAULT (0),
[FROMTOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMXFDMDDT__FROMT__73822AC7] DEFAULT (0),
[WRH] [int] NOT NULL CONSTRAINT [DF__NMXFDMDDTL__WRH__74764F00] DEFAULT (0),
[FROMTAX] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMXFDMDDT__FROMT__756A7339] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NMXFDMDDTL] ADD CONSTRAINT [PK__NMXFDMDDTL__765E9772] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
