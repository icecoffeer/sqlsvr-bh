CREATE TABLE [dbo].[EPSTASKMAN_ADJINVADVS]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLAG] [int] NOT NULL CONSTRAINT [DF__EPSTASKMAN__FLAG__7B0B109A] DEFAULT (0),
[SNDTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EPSTASKMAN_ADJINVADVS] ADD CONSTRAINT [PK__EPSTASKMAN_ADJIN__7BFF34D3] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
