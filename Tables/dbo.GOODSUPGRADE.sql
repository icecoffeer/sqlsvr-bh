CREATE TABLE [dbo].[GOODSUPGRADE]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL,
[RECCNT] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[ISTOSETTLE] [smallint] NOT NULL,
[RECCNTIN] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GOODSUPGRADE] ADD CONSTRAINT [PK__GOODSUPGRADE__741989A9] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
