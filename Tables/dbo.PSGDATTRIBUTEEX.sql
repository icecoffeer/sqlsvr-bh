CREATE TABLE [dbo].[PSGDATTRIBUTEEX]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GID] [int] NOT NULL,
[BGNDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[ACODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ATTSN] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PSGDATTRI__LSTUP__2CD77658] DEFAULT (getdate()),
[SENDTIME] [datetime] NULL,
[TAG] [smallint] NOT NULL CONSTRAINT [DF__PSGDATTRIBU__TAG__2DCB9A91] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSGDATTRIBUTEEX] ADD CONSTRAINT [PK__PSGDATTRIBUTEEX__2EBFBECA] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PSGDATTRIBUTEEX_N1] ON [dbo].[PSGDATTRIBUTEEX] ([GID], [BGNDATE], [ACODE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PSGDATTRIBUTEEX_N2] ON [dbo].[PSGDATTRIBUTEEX] ([GID], [ENDDATE], [ACODE]) ON [PRIMARY]
GO
