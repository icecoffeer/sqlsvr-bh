CREATE TABLE [dbo].[CTVDRPAYRTNLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[FROMSTAT] [smallint] NOT NULL,
[TOSTAT] [smallint] NOT NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTVDRPAYRTNLOG] ADD CONSTRAINT [PK__CTVDRPAYRTNLOG__62D52B04] PRIMARY KEY CLUSTERED  ([NUM], [ITEMNO]) ON [PRIMARY]
GO
