CREATE TABLE [dbo].[FAFLOWOBJMODULES]
(
[UUID] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[LINE] [int] NOT NULL,
[MODULEID] [int] NOT NULL,
[MODULENAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAFLOWOBJMODULES] ADD CONSTRAINT [PK__FAFLOWOBJMODULES__1BCDB13E] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO], [LINE]) ON [PRIMARY]
GO
