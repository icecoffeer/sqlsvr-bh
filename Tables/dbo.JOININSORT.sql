CREATE TABLE [dbo].[JOININSORT]
(
[STOREGID] [int] NOT NULL,
[POSITION] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[AREAKIND] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[AREA] [decimal] (24, 2) NULL,
[LEVEL] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESSHOUR] [decimal] (24, 2) NULL,
[TYPE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[WRHAREA] [decimal] (24, 2) NULL,
[BUSINESSTOWN] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESSCOUNT] [int] NULL,
[BUSINESSGRADE] [varchar] (24) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JOININSORT] ADD CONSTRAINT [PK__JOININSORT__0BA09FBF] PRIMARY KEY CLUSTERED  ([STOREGID]) ON [PRIMARY]
GO
