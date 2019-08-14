CREATE TABLE [dbo].[ClipaySettleDeptStore]
(
[SettleDeptCODE] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[StoreGid] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClipaySettleDeptStore] ADD CONSTRAINT [PK__ClipaySe__BF74923D4C168547] PRIMARY KEY CLUSTERED  ([SettleDeptCODE]) ON [PRIMARY]
GO
