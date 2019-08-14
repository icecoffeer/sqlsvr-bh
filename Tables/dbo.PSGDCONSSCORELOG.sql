CREATE TABLE [dbo].[PSGDCONSSCORELOG]
(
[CARDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__PSGDCONSS__OPERT__71A4CF4D] DEFAULT (getdate())
) ON [PRIMARY]
GO
