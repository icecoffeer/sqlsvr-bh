CREATE TABLE [dbo].[FAMODULEREFDEF]
(
[NO] [int] NOT NULL,
[REFCAPTION] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__FAMODULER__REFCA__616C057F] DEFAULT ('相关功能'),
[VISIBLE] [int] NOT NULL CONSTRAINT [DF__FAMODULER__VISIB__626029B8] DEFAULT (1),
[IMAGEINDEX] [int] NOT NULL CONSTRAINT [DF__FAMODULER__IMAGE__63544DF1] DEFAULT (0),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAMODULEREFDEF] ADD CONSTRAINT [PK__FAMODULEREFDEF__6448722A] PRIMARY KEY CLUSTERED  ([NO]) ON [PRIMARY]
GO
