CREATE TABLE [dbo].[RBActionLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[actionClass] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[actionCaption] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBActionLog] ADD CONSTRAINT [PK__RBActionLog__7B01BA50] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
