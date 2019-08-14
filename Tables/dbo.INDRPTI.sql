CREATE TABLE [dbo].[INDRPTI]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BVDRGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[CQ1] [money] NULL CONSTRAINT [DF__INDRPTI__CQ1__30F91444] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__INDRPTI__CQ2__31ED387D] DEFAULT (0),
[CQ3] [money] NULL CONSTRAINT [DF__INDRPTI__CQ3__32E15CB6] DEFAULT (0),
[CQ4] [money] NULL CONSTRAINT [DF__INDRPTI__CQ4__33D580EF] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__INDRPTI__CT1__34C9A528] DEFAULT (0),
[CT2] [money] NULL CONSTRAINT [DF__INDRPTI__CT2__35BDC961] DEFAULT (0),
[CT3] [money] NULL CONSTRAINT [DF__INDRPTI__CT3__36B1ED9A] DEFAULT (0),
[CT4] [money] NULL CONSTRAINT [DF__INDRPTI__CT4__37A611D3] DEFAULT (0),
[CI1] [money] NULL CONSTRAINT [DF__INDRPTI__CI1__389A360C] DEFAULT (0),
[CI2] [money] NULL CONSTRAINT [DF__INDRPTI__CI2__398E5A45] DEFAULT (0),
[CI3] [money] NULL CONSTRAINT [DF__INDRPTI__CI3__3A827E7E] DEFAULT (0),
[CI4] [money] NULL CONSTRAINT [DF__INDRPTI__CI4__3B76A2B7] DEFAULT (0),
[CR1] [money] NULL CONSTRAINT [DF__INDRPTI__CR1__3C6AC6F0] DEFAULT (0),
[CR2] [money] NULL CONSTRAINT [DF__INDRPTI__CR2__3D5EEB29] DEFAULT (0),
[CR3] [money] NULL CONSTRAINT [DF__INDRPTI__CR3__3E530F62] DEFAULT (0),
[CR4] [money] NULL CONSTRAINT [DF__INDRPTI__CR4__3F47339B] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INDRPTI] ADD CONSTRAINT [PK__INDRPTI__6F4A8121] PRIMARY KEY CLUSTERED  ([ADATE], [BGDGID], [BVDRGID], [BWRH], [ASETTLENO], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO