CREATE TABLE [dbo].[VDRLOCKLOG]
(
[ID] [int] NOT NULL,
[VDRGID] [int] NOT NULL,
[ACTION] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VDRLOCK_LOG] ON [dbo].[VDRLOCKLOG] ([ID]) ON [PRIMARY]
GO
