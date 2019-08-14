CREATE TABLE [dbo].[fifolog]
(
[time] [datetime] NOT NULL CONSTRAINT [DF__fifolog__time__352B2E89] DEFAULT (getdate()),
[adate] [datetime] NOT NULL CONSTRAINT [DF__fifolog__adate__361F52C2] DEFAULT (getdate()),
[content] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fifolog] ADD CONSTRAINT [PK__fifolog__5B438874] PRIMARY KEY CLUSTERED  ([time]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
