CREATE TABLE [dbo].[STOREORDAPPLYTYPE]
(
[TYPE] [int] NOT NULL,
[TYPENAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[STATNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STOREORDAPPLYTYPE] ADD CONSTRAINT [PK__StoreOrdApplyTyp__1D5606FD] PRIMARY KEY CLUSTERED  ([TYPE], [STAT]) ON [PRIMARY]
GO