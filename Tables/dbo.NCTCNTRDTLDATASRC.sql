CREATE TABLE [dbo].[NCTCNTRDTLDATASRC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[DSCODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRDTLDATASRC] ADD CONSTRAINT [PK__NCTCNTRDTLDATASR__22859BC5] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [DSCODE]) ON [PRIMARY]
GO
