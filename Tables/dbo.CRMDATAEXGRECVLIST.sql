CREATE TABLE [dbo].[CRMDATAEXGRECVLIST]
(
[FRECVTIME] [datetime] NOT NULL,
[FCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FSRCORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FDESTORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMDATAEXGRECVLIST] ADD CONSTRAINT [PK__CRMDATAEXGRECVLI__1E9FFC48] PRIMARY KEY CLUSTERED  ([FSRCORG], [FDESTORG], [FCLS]) ON [PRIMARY]
GO