CREATE TABLE [dbo].[INVCHGDRPTX]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[DIN1] [money] NOT NULL CONSTRAINT [DF__INVCHGDRPT__DIN1__75A4DAFA] DEFAULT (0),
[DIN2] [money] NOT NULL CONSTRAINT [DF__INVCHGDRPT__DIN2__7698FF33] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INVCHGDRPTX] ADD CONSTRAINT [PK__INVCHGDRPTX__7ABC33CD] PRIMARY KEY CLUSTERED  ([ADATE], [BGDGID], [BWRH], [ASETTLENO], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
