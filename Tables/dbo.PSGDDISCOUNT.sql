CREATE TABLE [dbo].[PSGDDISCOUNT]
(
[GID] [int] NOT NULL,
[DISCOUNT] [decimal] (24, 4) NOT NULL,
[EXDIS] [int] NOT NULL CONSTRAINT [DF__PSGDDISCO__EXDIS__775DA8A3] DEFAULT (0),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSGDDISCOUNT] ADD CONSTRAINT [PK__PSGDDISCOUNT__7851CCDC] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
