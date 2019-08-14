CREATE TABLE [dbo].[GDSCORE]
(
[STORE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[SCORE] [money] NOT NULL CONSTRAINT [DF__GDSCORE__SCORE__4071F8AC] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDSCORE] ADD CONSTRAINT [PK__GDSCORE__61F08603] PRIMARY KEY CLUSTERED  ([STORE], [GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
