CREATE TABLE [dbo].[PROPERTY]
(
[NO] [smallint] NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROPERTY] ADD CONSTRAINT [PK__PROPERTY__7F4BDEC0] PRIMARY KEY CLUSTERED  ([NO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
