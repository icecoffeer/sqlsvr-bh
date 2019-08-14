CREATE TABLE [dbo].[CLNSTYLE]
(
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OUTPRC] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CLNSTYLE__OUTPRC__2C75ECF7] DEFAULT ('WHSPRC'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CLNSTYLE__CREATO__2D6A1130] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CLNSTYLE__CREATE__2E5E3569] DEFAULT (getdate()),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CLNSTYLE__MODIFI__2F5259A2] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CLNSTYLE__LSTUPD__30467DDB] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CLNSTYLE] ADD CONSTRAINT [PK__CLNSTYLE__2B81C8BE] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO