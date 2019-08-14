CREATE TABLE [dbo].[CMDECFACTOR]
(
[CMCODE] [char] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DECFACTORCODE] [char] (1) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CMDECFACTO__RATE__3266327C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CMDECFACTOR] ADD CONSTRAINT [PK__CMDECFACTOR__335A56B5] PRIMARY KEY CLUSTERED  ([CMCODE], [DECFACTORCODE]) ON [PRIMARY]
GO
