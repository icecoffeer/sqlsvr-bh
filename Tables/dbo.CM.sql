CREATE TABLE [dbo].[CM]
(
[CODE] [char] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DECTREEINFO] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CREATETIME] [datetime] NOT NULL,
[CREATEOPER] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LASTMODIFYTIME] [datetime] NOT NULL,
[LASTMODIFYOPER] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CM] ADD CONSTRAINT [PK__CM__1F535E08] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
