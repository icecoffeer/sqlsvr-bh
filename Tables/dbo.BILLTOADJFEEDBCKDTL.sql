CREATE TABLE [dbo].[BILLTOADJFEEDBCKDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__BILLTOADJF__STAT__6F09251B] DEFAULT (0),
[RTNNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BILLTOADJFEEDBCKDTL] ADD CONSTRAINT [PK__BILLTOADJFEEDBCK__6FFD4954] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
