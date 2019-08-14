CREATE TABLE [dbo].[PROCMRPT]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[CQ1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__CQ1__32B8D632] DEFAULT (0),
[CT1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__CT1__33ACFA6B] DEFAULT (0),
[CI1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__CI1__34A11EA4] DEFAULT (0),
[CR1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__CR1__359542DD] DEFAULT (0),
[CD1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__CD1__36896716] DEFAULT (0),
[DQ1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__DQ1__377D8B4F] DEFAULT (0),
[DT1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__DT1__3871AF88] DEFAULT (0),
[DI1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__DI1__3965D3C1] DEFAULT (0),
[DR1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__DR1__3A59F7FA] DEFAULT (0),
[DD1] [money] NOT NULL CONSTRAINT [DF__PROCMRPT__DD1__3B4E1C33] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROCMRPT] ADD CONSTRAINT [PK__PROCMRPT__7D63964E] PRIMARY KEY CLUSTERED  ([ASETTLENO], [BGDGID], [BWRH], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
