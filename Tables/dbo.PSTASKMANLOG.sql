CREATE TABLE [dbo].[PSTASKMANLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[FROMSTAT] [smallint] NULL,
[TOSTAT] [smallint] NOT NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL,
[SETTLENO] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSTASKMANLOG] ADD CONSTRAINT [PK__PSTASKMANLOG__6DB1157C] PRIMARY KEY CLUSTERED  ([NUM], [ITEMNO]) ON [PRIMARY]
GO
