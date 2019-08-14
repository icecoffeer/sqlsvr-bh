CREATE TABLE [dbo].[CRMWEBEMP]
(
[GID] [int] NOT NULL,
[ISWEBUSER] [smallint] NOT NULL CONSTRAINT [DF__CRMWEBEMP__ISWEB__4D8FF55B] DEFAULT (0),
[WEBPWD] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[STARTDATE] [datetime] NULL,
[ENDDATE] [datetime] NULL,
[INEFFECT] [smallint] NOT NULL CONSTRAINT [DF__CRMWEBEMP__INEFF__4E841994] DEFAULT (0),
[STORE] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__CRMWEBEMP__SRC__4F783DCD] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CRMWEBEMP__CREAT__506C6206] DEFAULT (getdate()),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMWEBEMP__LSTUP__5160863F] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMWEBEMP__LSTUP__5254AA78] DEFAULT ('未知[-]'),
[SYSUUID] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMWEBEMP] ADD CONSTRAINT [PK__CRMWEBEMP__5348CEB1] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
