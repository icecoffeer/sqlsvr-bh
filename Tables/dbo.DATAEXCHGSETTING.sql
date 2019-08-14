CREATE TABLE [dbo].[DATAEXCHGSETTING]
(
[BUSCLS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RECALSHOULDSP] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[RECALREALSP] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHECKSP] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[USED] [smallint] NOT NULL CONSTRAINT [DF__DATAEXCHGS__USED__1EC620C7] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DATAEXCHGSETTING] ADD CONSTRAINT [PK__DATAEXCHGSETTING__1DD1FC8E] PRIMARY KEY CLUSTERED  ([CLS]) ON [PRIMARY]
GO
