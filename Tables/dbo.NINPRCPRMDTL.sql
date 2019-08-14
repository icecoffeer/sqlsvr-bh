CREATE TABLE [dbo].[NINPRCPRMDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[ASTART] [datetime] NOT NULL CONSTRAINT [DF__NINPRCPRM__ASTAR__2CC95C04] DEFAULT (getdate()),
[AFINISH] [datetime] NOT NULL CONSTRAINT [DF__NINPRCPRM__AFINI__2DBD803D] DEFAULT ('9999.12.31 23:59:59'),
[PRICE] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINPRCPRMDTL] ADD CONSTRAINT [PK__NINPRCPRMDTL__2BD537CB] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
