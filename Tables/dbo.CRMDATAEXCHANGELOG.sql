CREATE TABLE [dbo].[CRMDATAEXCHANGELOG]
(
[FTIME] [datetime] NOT NULL,
[FACTION] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FSRCORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FDESTORG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FEXGCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FMESSAGE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DATAEXGLOG_FTIME] ON [dbo].[CRMDATAEXCHANGELOG] ([FTIME]) ON [PRIMARY]
GO
