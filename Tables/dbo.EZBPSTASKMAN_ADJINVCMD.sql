CREATE TABLE [dbo].[EZBPSTASKMAN_ADJINVCMD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLAG] [int] NOT NULL CONSTRAINT [DF__EZBPSTASKM__FLAG__11EE75F2] DEFAULT (0),
[SNDTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EZBPSTASKMAN_ADJINVCMD] ADD CONSTRAINT [PK__EZBPSTASKMAN_ADJ__12E29A2B] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO