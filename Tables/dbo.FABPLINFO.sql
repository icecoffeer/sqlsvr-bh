CREATE TABLE [dbo].[FABPLINFO]
(
[BINNAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRELOAD] [smallint] NOT NULL CONSTRAINT [DF__FABPLINFO__PRELO__788CFFF4] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FABPLINFO] ADD CONSTRAINT [PK__FABPLINFO__7981242D] PRIMARY KEY CLUSTERED  ([BINNAME]) ON [PRIMARY]
GO
