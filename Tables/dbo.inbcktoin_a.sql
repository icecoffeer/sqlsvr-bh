CREATE TABLE [dbo].[inbcktoin_a]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[line] [int] NOT NULL,
[qty] [money] NOT NULL CONSTRAINT [DF__inbcktoin_a__qty__735C9FD5] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inbcktoin_a] ADD CONSTRAINT [PK__inbcktoin_a__6EEC251C] PRIMARY KEY CLUSTERED  ([id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
