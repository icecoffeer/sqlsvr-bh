CREATE TABLE [dbo].[PSCSSSTOREINVINITINFO]
(
[NO] [int] NOT NULL,
[FILTIME] [datetime] NOT NULL CONSTRAINT [DF__PSCSSSTOR__FILTI__104624A2] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCSSSTOREINVINITINFO] ADD CONSTRAINT [PK__PSCSSSTOREINVINI__113A48DB] PRIMARY KEY CLUSTERED  ([NO]) ON [PRIMARY]
GO
