CREATE TABLE [dbo].[CSTYRPT]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BCSTGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[CQ1] [money] NULL CONSTRAINT [DF__CSTYRPT__CQ1__67AA2AB0] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__CSTYRPT__CQ2__689E4EE9] DEFAULT (0),
[CQ3] [money] NULL CONSTRAINT [DF__CSTYRPT__CQ3__69927322] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__CSTYRPT__CT1__6A86975B] DEFAULT (0),
[CT2] [money] NULL CONSTRAINT [DF__CSTYRPT__CT2__6B7ABB94] DEFAULT (0),
[CT3] [money] NULL CONSTRAINT [DF__CSTYRPT__CT3__6C6EDFCD] DEFAULT (0),
[CT4] [money] NULL CONSTRAINT [DF__CSTYRPT__CT4__6D630406] DEFAULT (0),
[DQ1] [money] NULL CONSTRAINT [DF__CSTYRPT__DQ1__6E57283F] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__CSTYRPT__DQ2__6F4B4C78] DEFAULT (0),
[DQ3] [money] NULL CONSTRAINT [DF__CSTYRPT__DQ3__703F70B1] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__CSTYRPT__DT1__713394EA] DEFAULT (0),
[DT2] [money] NULL CONSTRAINT [DF__CSTYRPT__DT2__7227B923] DEFAULT (0),
[DT3] [money] NULL CONSTRAINT [DF__CSTYRPT__DT3__731BDD5C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSTYRPT] ADD CONSTRAINT [PK__CSTYRPT__3CBF0154] PRIMARY KEY CLUSTERED  ([ASETTLENO], [BCSTGID], [BGDGID], [BWRH], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
