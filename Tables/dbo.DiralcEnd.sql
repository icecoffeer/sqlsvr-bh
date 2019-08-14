CREATE TABLE [dbo].[DiralcEnd]
(
[Settleno] [int] NOT NULL,
[EndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiralcEnd] ADD CONSTRAINT [PK__DiralcEnd__48013937] PRIMARY KEY CLUSTERED  ([Settleno]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
