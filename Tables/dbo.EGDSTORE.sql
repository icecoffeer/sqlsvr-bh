CREATE TABLE [dbo].[EGDSTORE]
(
[STOREGID] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[FLAG] [smallint] NOT NULL CONSTRAINT [DF__EGDSTORE__FLAG__18D83D47] DEFAULT (0),
[LSTUPDTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EGDSTORE] ADD CONSTRAINT [PK__EGDSTORE__17E4190E] PRIMARY KEY CLUSTERED  ([STOREGID], [GDGID]) ON [PRIMARY]
GO