CREATE TABLE [dbo].[CTCNTRDTLDATASRC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[DSCODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRDTLDATASRC] ADD CONSTRAINT [PK__CTCNTRDTLDATASRC__5BF3234B] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE], [DSCODE]) ON [PRIMARY]
GO
