CREATE TABLE [dbo].[CMLOG]
(
[OPER] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODTIME] [datetime] NOT NULL,
[CMCODE] [char] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CMSCODE] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CMLOG_COM] ON [dbo].[CMLOG] ([CMCODE], [OPER], [MODTIME]) ON [PRIMARY]
GO