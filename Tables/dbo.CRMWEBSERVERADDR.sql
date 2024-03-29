CREATE TABLE [dbo].[CRMWEBSERVERADDR]
(
[ADDR] [char] (200) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__CRMWEBSERVE__SRC__20533A90] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CRMWEBSER__CREAT__21475EC9] DEFAULT (getdate()),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMWEBSER__LSTUP__223B8302] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMWEBSER__LSTUP__232FA73B] DEFAULT ('未知[-]'),
[FLAG] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMWEBSERV__FLAG__2423CB74] DEFAULT ('0000000000'),
[SYSUUID] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMWEBSERVERADDR] ADD CONSTRAINT [PK__CRMWEBSERVERADDR__2517EFAD] PRIMARY KEY CLUSTERED  ([ADDR]) ON [PRIMARY]
GO
