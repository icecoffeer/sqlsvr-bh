CREATE TABLE [dbo].[MEASUREUNIT]
(
[NO] [smallint] NOT NULL,
[NAME] [char] (6) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MEASUREUNIT] ADD CONSTRAINT [PK__MEASUREUNIT__0CDAE408] PRIMARY KEY CLUSTERED  ([NO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
