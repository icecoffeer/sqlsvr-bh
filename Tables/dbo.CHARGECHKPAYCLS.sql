CREATE TABLE [dbo].[CHARGECHKPAYCLS]
(
[CODE] [smallint] NOT NULL,
[NAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PAYTYPE] [smallint] NOT NULL CONSTRAINT [DF__CHARGECHK__PAYTY__73F4CA0E] DEFAULT (0),
[ISCLIENT] [smallint] NOT NULL CONSTRAINT [DF__CHARGECHK__ISCLI__74E8EE47] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__CHARGECHKP__STAT__4504D0FB] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHARGECHKPAYCLS] ADD CONSTRAINT [PK__CHARGECHKPAYCLS__75DD1280] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO