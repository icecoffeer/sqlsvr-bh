CREATE TABLE [dbo].[PS3DISNOTDISCOUNTGOODS]
(
[GDGID] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3DISNOTDISCOUNTGOODS] ADD CONSTRAINT [PK__PS3DISNOTDISCOUN__33D8AE4B] PRIMARY KEY CLUSTERED  ([GDGID]) ON [PRIMARY]
GO