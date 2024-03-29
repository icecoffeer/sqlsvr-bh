CREATE TABLE [dbo].[GFTPRMSNDBILL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[FLOWNO] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GFTPRMSNDBI__AMT__7D85F3E4] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GFTPRMSNDBILL] ADD CONSTRAINT [PK__GFTPRMSNDBILL__7C91CFAB] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
