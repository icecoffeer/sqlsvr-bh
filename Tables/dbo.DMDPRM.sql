CREATE TABLE [dbo].[DMDPRM]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__DMDPRM__FILDATE__24D4CB2F] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__DMDPRM__FILLER__25C8EF68] DEFAULT (1),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__DMDPRM__RECCNT__26BD13A1] DEFAULT (0),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__DMDPRM__STAT__27B137DA] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EON] [smallint] NOT NULL CONSTRAINT [DF__DMDPRM__EON__28A55C13] DEFAULT (1),
[SRC] [int] NOT NULL CONSTRAINT [DF__DMDPRM__SRC__2999804C] DEFAULT (1),
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[RATIFYSTORE] [int] NOT NULL,
[SUBMITDATE] [datetime] NULL,
[SUBMITTER] [int] NULL,
[RATIFYDATE] [datetime] NULL,
[RATIFIER] [int] NULL,
[CHKFLAG] [smallint] NULL CONSTRAINT [DF__DMDPRM__CHKFLAG__070F5E1E] DEFAULT (0),
[EFFECTSTORE] [varchar] (2000) COLLATE Chinese_PRC_CI_AS NULL,
[LAUNCH] [datetime] NULL,
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CANCELDATE] [datetime] NULL,
[CANCELER] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DMDPRM] WITH NOCHECK ADD CONSTRAINT [DMDPRM_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[DMDPRM] ADD CONSTRAINT [PK__DMDPRM__4830B400] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[DMDPRM] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
