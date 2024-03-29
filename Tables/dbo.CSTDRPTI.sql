CREATE TABLE [dbo].[CSTDRPTI]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BCSTGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[CQ1] [money] NULL CONSTRAINT [DF__CSTDRPTI__CQ1__4925A390] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__CSTDRPTI__CQ2__4A19C7C9] DEFAULT (0),
[CQ3] [money] NULL CONSTRAINT [DF__CSTDRPTI__CQ3__4B0DEC02] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__CSTDRPTI__CT1__4C02103B] DEFAULT (0),
[CT2] [money] NULL CONSTRAINT [DF__CSTDRPTI__CT2__4CF63474] DEFAULT (0),
[CT3] [money] NULL CONSTRAINT [DF__CSTDRPTI__CT3__4DEA58AD] DEFAULT (0),
[CT4] [money] NULL CONSTRAINT [DF__CSTDRPTI__CT4__4EDE7CE6] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSTDRPTI] ADD CONSTRAINT [PK__CSTDRPTI__38EE7070] PRIMARY KEY CLUSTERED  ([ASETTLENO], [ADATE], [BCSTGID], [BGDGID], [BWRH], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
