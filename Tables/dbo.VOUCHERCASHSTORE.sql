CREATE TABLE [dbo].[VOUCHERCASHSTORE]
(
[UUID] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERCASHSTORE] ADD CONSTRAINT [PK__VOUCHERCASHSTORE__0C2224B1] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VOUCHERCASHSTORE_NUM] ON [dbo].[VOUCHERCASHSTORE] ([NUM]) ON [PRIMARY]
GO
