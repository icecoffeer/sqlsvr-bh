CREATE TABLE [dbo].[EMPLOYEEH]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[IDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[WORKTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[DISCOUNT] [money] NOT NULL CONSTRAINT [DF__EMPLOYEEH__DISCO__051B5D5D] DEFAULT (100),
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__EMPLOYEEH__CREAT__060F8196] DEFAULT (getdate()),
[PASSWORD] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[LOCALRIGHT] [text] COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__EMPLOYEEH__LOCAL__0703A5CF] DEFAULT (''),
[LOCALEXTRARIGHT] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__EMPLOYEEH__LOCAL__07F7CA08] DEFAULT (''),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__EMPLOYEEH__SRC__08EBEE41] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__EMPLOYEEH__LSTUP__09E0127A] DEFAULT (getdate()),
[ISUSETOKEN] [smallint] NOT NULL CONSTRAINT [DF__EMPLOYEEH__ISUSE__4ED5269C] DEFAULT (0),
[ISSPECLIM] [smallint] NOT NULL CONSTRAINT [DF__EMPLOYEEH__ISSPE__3F2CC76B] DEFAULT (0),
[SECURITYSTY] [int] NOT NULL CONSTRAINT [DF__EMPLOYEEH__SECUR__5BEC2F06] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EMPLOYEEH] ADD CONSTRAINT [PK__EMPLOYEEH__53A266AC] PRIMARY KEY CLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
