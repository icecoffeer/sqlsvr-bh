CREATE TABLE [dbo].[CRMDEV]
(
[SYSUUID] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEVUUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDEV__CREATOR__431266E8] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CRMDEV__CREATETI__44068B21] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMDEV__LSTUPDOP__44FAAF5A] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMDEV__LSTUPDTI__45EED393] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMDEV] ADD CONSTRAINT [PK__CRMDEV__46E2F7CC] PRIMARY KEY CLUSTERED  ([SYSUUID], [DEVUUID]) ON [PRIMARY]
GO
