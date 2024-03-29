CREATE TABLE [dbo].[CURGDBCKNOTIFY]
(
[GDGID] [int] NOT NULL,
[STOREGID] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VDRGID] [datetime] NOT NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL,
[BCKFALG] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CURGDBCKN__BCKFA__42485FE1] DEFAULT ('特退'),
[LIMITQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CURGDBCKN__LIMIT__433C841A] DEFAULT (0),
[LSTBCKDATE] [datetime] NOT NULL,
[ACTION] [smallint] NOT NULL,
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CURGDBCKN__SRCNU__4430A853] DEFAULT ('-'),
[SNDTIME] [datetime] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CURGDBCKNOTIFY] ADD CONSTRAINT [PK__CURGDBCKNOTIFY__4524CC8C] PRIMARY KEY CLUSTERED  ([GDGID], [STOREGID]) ON [PRIMARY]
GO
