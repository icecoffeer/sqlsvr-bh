CREATE TABLE [dbo].[GOODSAPPFIELD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[FIELDNAME] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GOODSAPPFIELD] ADD CONSTRAINT [PK__GOODSAPPFIELD__5AFBD1B6] PRIMARY KEY CLUSTERED  ([NUM], [FIELDNAME]) ON [PRIMARY]
GO
