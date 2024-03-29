CREATE TABLE [dbo].[PRCPRM]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[FILDATE] [datetime] NULL CONSTRAINT [DF__PRCPRM__FILDATE__5FC911C6] DEFAULT (getdate()),
[FILLER] [int] NULL CONSTRAINT [DF__PRCPRM__FILLER__60BD35FF] DEFAULT (1),
[CHECKER] [int] NULL CONSTRAINT [DF__PRCPRM__CHECKER__61B15A38] DEFAULT (1),
[RECCNT] [int] NULL CONSTRAINT [DF__PRCPRM__RECCNT__62A57E71] DEFAULT (0),
[STAT] [smallint] NULL CONSTRAINT [DF__PRCPRM__STAT__6399A2AA] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EON] [smallint] NULL CONSTRAINT [DF__PRCPRM__EON__648DC6E3] DEFAULT (1),
[SRC] [int] NULL CONSTRAINT [DF__PRCPRM__SRC__6581EB1C] DEFAULT (1),
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[LAUNCH] [datetime] NULL,
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OVERWRITERULE] [smallint] NOT NULL CONSTRAINT [DF__PRCPRM__OVERWRIT__494B2E82] DEFAULT (1),
[PSETTLENO] [int] NULL,
[PRIORITY] [int] NOT NULL CONSTRAINT [DF__PRCPRM__PRIORITY__3C91E890] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCPRM] WITH NOCHECK ADD CONSTRAINT [PRCPRM_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[PRCPRM] ADD CONSTRAINT [PK__PRCPRM__76B698BF] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[PRCPRM] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
