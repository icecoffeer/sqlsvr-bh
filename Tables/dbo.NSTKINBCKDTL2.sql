CREATE TABLE [dbo].[NSTKINBCKDTL2]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__NSTKINBCKDT__QTY__49E588F6] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__NSTKINBCKD__COST__4AD9AD2F] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTKINBCKDTL2] ADD CONSTRAINT [PK__NSTKINBCKDTL2__48F164BD] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [SUBWRH]) ON [PRIMARY]
GO