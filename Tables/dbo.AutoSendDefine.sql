CREATE TABLE [dbo].[AutoSendDefine]
(
[Subject] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Receiver] [int] NOT NULL,
[SendTime] [int] NOT NULL CONSTRAINT [DF__AutoSendD__SendT__5FA15699] DEFAULT (4),
[AutoCheckDay] [int] NOT NULL CONSTRAINT [DF__AutoSendD__AutoC__60957AD2] DEFAULT (1),
[SPName] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoSendDefine] ADD CONSTRAINT [PK__AutoSendDefine__5EAD3260] PRIMARY KEY CLUSTERED  ([Subject], [Receiver]) ON [PRIMARY]
GO
