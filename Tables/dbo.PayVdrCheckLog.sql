CREATE TABLE [dbo].[PayVdrCheckLog]
(
[Cls] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Num] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CheckTime] [datetime] NOT NULL CONSTRAINT [DF__PayVdrChe__Check__7FB789C2] DEFAULT (getdate()),
[Checker] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayVdrCheckLog] ADD CONSTRAINT [PK__PAYVDRCHECKLOG__1EDE5CBC] PRIMARY KEY CLUSTERED  ([Cls], [Num]) ON [PRIMARY]
GO
