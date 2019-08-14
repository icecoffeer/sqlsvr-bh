CREATE TABLE [dbo].[BCPUIOPT]
(
[OBJNAME] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FIELDNAME] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSITION] [smallint] NOT NULL,
[ISVISIBLE] [smallint] NOT NULL CONSTRAINT [DF__BCPUIOPT__ISVISI__757ABDC8] DEFAULT (0),
[PAGE] [smallint] NOT NULL CONSTRAINT [DF__BCPUIOPT__PAGE__79EE65DD] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BCPUIOPT] ADD CONSTRAINT [PK__BCPUIOPT__15A53433] PRIMARY KEY CLUSTERED  ([OBJNAME], [FIELDNAME]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BCPUIOPT] ADD CONSTRAINT [UQ__BCPUIOPT__58F12BAE] UNIQUE NONCLUSTERED  ([OBJNAME], [POSITION]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO