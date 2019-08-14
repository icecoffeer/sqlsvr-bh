CREATE TABLE [dbo].[PSMKTIVGTTYPE]
(
[CODE] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATETIME] [datetime] NULL CONSTRAINT [DF__PSMKTIVGT__CREAT__196E057B] DEFAULT (getdate()),
[SNDTIME] [datetime] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PSMKTIVGTT__STAT__1A6229B4] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSMKTIVGTTYPE] ADD CONSTRAINT [PK__PSMKTIVGTTYPE__1879E142] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO