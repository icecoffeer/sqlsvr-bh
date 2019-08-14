CREATE TABLE [dbo].[ECSNDITEM]
(
[ID] [int] NOT NULL,
[NAME] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TABLENAME] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[ETABLENAME] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[DATATYPE] [char] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SENDSP] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[LSTSNDTIME] [datetime] NULL,
[LISTSQL] [varchar] (512) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ECSNDITEM] ADD CONSTRAINT [PK__ECSNDITEM__0995F9B7] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO