CREATE TABLE [dbo].[STATRIGHT]
(
[MODULENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL,
[SPECRIGHTNO] [int] NOT NULL,
[LOCALRIGHT] [int] NOT NULL,
[NETRIGHT] [int] NOT NULL,
[SPECRIGHTNO2] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__STATRIGHT__SPECR__30B15D86] DEFAULT ('-')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STATRIGHT] ADD CONSTRAINT [PK__STATRIGHT__6411D152] PRIMARY KEY CLUSTERED  ([MODULENO], [STAT], [SPECRIGHTNO], [SPECRIGHTNO2]) ON [PRIMARY]
GO
