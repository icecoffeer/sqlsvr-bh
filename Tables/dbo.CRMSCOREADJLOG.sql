CREATE TABLE [dbo].[CRMSCOREADJLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[FROMSTAT] [smallint] NULL,
[TOSTAT] [smallint] NOT NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSCOREADJLOG] ADD CONSTRAINT [PK__CRMSCOREADJLOG__350BFE4F] PRIMARY KEY CLUSTERED  ([NUM], [ITEMNO]) ON [PRIMARY]
GO
