CREATE TABLE [dbo].[LMTPRM]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__LMTPRM__FILDATE__7ECD872A] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__LMTPRM__FILLER__7FC1AB63] DEFAULT (1),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__LMTPRM__CHECKER__00B5CF9C] DEFAULT (1),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__LMTPRM__RECCNT__01A9F3D5] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__LMTPRM__STAT__029E180E] DEFAULT (0),
[LMTCLS] [smallint] NOT NULL CONSTRAINT [DF__LMTPRM__LMTCLS__03923C47] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EON] [smallint] NOT NULL CONSTRAINT [DF__LMTPRM__EON__04866080] DEFAULT (1),
[SRC] [int] NOT NULL CONSTRAINT [DF__LMTPRM__SRC__057A84B9] DEFAULT (1),
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[RcvTIME] [datetime] NULL,
[PSETTLENO] [int] NULL,
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LMTPRM] ADD CONSTRAINT [LMTPRM_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[LMTPRM] ADD CONSTRAINT [PK__LMTPRM__7DD962F1] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[LMTPRM] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO