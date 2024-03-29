CREATE TABLE [dbo].[POLYPAYRATEPRM]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__POLYPAYRAT__STAT__3306E7A8] DEFAULT (0),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__POLYPAYRA__FILDA__33FB0BE1] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__POLYPAYRA__LSTUP__34EF301A] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__POLYPAYRA__LSTUP__35E35453] DEFAULT ('未知[-]'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL CONSTRAINT [DF__POLYPAYRA__SETTL__36D7788C] DEFAULT (0),
[RECCNT] [int] NOT NULL,
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PSETTLENO] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYPAYRATEPRM] ADD CONSTRAINT [PK__POLYPAYRATEPRM__37CB9CC5] PRIMARY KEY CLUSTERED  ([NUM], [CLS]) ON [PRIMARY]
GO
