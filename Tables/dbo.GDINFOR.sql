CREATE TABLE [dbo].[GDINFOR]
(
[GDGID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[TM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDINFOR] ADD CONSTRAINT [PK__GDINFOR__5F141958] PRIMARY KEY CLUSTERED  ([GDGID], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO