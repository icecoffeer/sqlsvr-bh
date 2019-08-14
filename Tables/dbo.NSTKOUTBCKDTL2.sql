CREATE TABLE [dbo].[NSTKOUTBCKDTL2]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__NSTKOUTBCKD__QTY__5186AABE] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__NSTKOUTBCK__COST__527ACEF7] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTKOUTBCKDTL2] ADD CONSTRAINT [PK__NSTKOUTBCKDTL2__50928685] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [SUBWRH]) ON [PRIMARY]
GO