CREATE TABLE [dbo].[CQNSORT]
(
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNSORT__NSTAT__3151475B] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNSORT__EXTIME__32456B94] DEFAULT (getdate()),
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDCOUNT] [int] NOT NULL CONSTRAINT [DF__CQNSORT__GDCOUNT__33398FCD] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNSORT] ADD CONSTRAINT [PK__CQNSORT__342DB406] PRIMARY KEY CLUSTERED  ([NTYPE], [GROUPID], [CODE]) ON [PRIMARY]
GO
