CREATE TABLE [dbo].[AddrInfo]
(
[Code] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MEMO] [varchar] (127) COLLATE Chinese_PRC_CI_AS NULL,
[CreateDate] [datetime] NOT NULL,
[LstUpdTime] [datetime] NOT NULL,
[SndTime] [datetime] NULL,
[Filler] [int] NOT NULL,
[Modifier] [int] NULL,
[Src] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AddrInfo] ADD CONSTRAINT [PK__AddrInfo__418F6EC0] PRIMARY KEY CLUSTERED  ([Code]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
