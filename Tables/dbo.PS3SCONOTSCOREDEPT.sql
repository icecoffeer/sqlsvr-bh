CREATE TABLE [dbo].[PS3SCONOTSCOREDEPT]
(
[DEPT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SCONOTSCOREDEPT] ADD CONSTRAINT [PK__PS3SCONOTSCOREDE__09E2747F] PRIMARY KEY CLUSTERED  ([DEPT]) ON [PRIMARY]
GO
