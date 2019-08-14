CREATE TABLE [dbo].[MKTPRCSCHEMESTOREDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__MKTPRCSCHE__STAT__281DAE33] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MKTPRCSCHEMESTOREDTL] ADD CONSTRAINT [PK__MktPrcSchemeStor__2911D26C] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO