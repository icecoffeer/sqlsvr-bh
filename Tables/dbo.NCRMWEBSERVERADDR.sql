CREATE TABLE [dbo].[NCRMWEBSERVERADDR]
(
[ADDR] [varchar] (200) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NCRMWEBSERV__SRC__637F367A] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__NCRMWEBSE__CREAT__64735AB3] DEFAULT (getdate()),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NCRMWEBSE__LSTUP__65677EEC] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCRMWEBSE__LSTUP__665BA325] DEFAULT ('未知[-]'),
[ID] [int] NOT NULL,
[RCV] [int] NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SYSUUID] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCRMWEBSE__SYSUU__674FC75E] DEFAULT ('-'),
[FLAG] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCRMWEBSERVERADDR] ADD CONSTRAINT [PK__NCRMWEBSERVERADD__6843EB97] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
