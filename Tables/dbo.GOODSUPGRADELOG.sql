CREATE TABLE [dbo].[GOODSUPGRADELOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACTION] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_GOODSUPGRADELOG_NUM] ON [dbo].[GOODSUPGRADELOG] ([NUM]) ON [PRIMARY]
GO
