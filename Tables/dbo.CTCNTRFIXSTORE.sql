CREATE TABLE [dbo].[CTCNTRFIXSTORE]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[STORESCOPE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CTCNTRFIX__TOTAL__3BBB5DE3] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRFIXSTORE] ADD CONSTRAINT [PK__CTCNTRFIXSTORE__3CAF821C] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE], [ITEMNO]) ON [PRIMARY]
GO
