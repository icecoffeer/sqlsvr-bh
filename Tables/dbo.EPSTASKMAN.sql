CREATE TABLE [dbo].[EPSTASKMAN]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLAG] [int] NOT NULL CONSTRAINT [DF__EPSTASKMAN__FLAG__6F995DEE] DEFAULT (0),
[SNDTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EPSTASKMAN] ADD CONSTRAINT [PK__EPSTASKMAN__708D8227] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
