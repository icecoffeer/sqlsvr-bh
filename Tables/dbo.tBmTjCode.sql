CREATE TABLE [dbo].[tBmTjCode]
(
[TjType] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TjCode] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TjName] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Remark] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[qtyname] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[amtname] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[qtyunit] [int] NULL,
[amtunit] [int] NULL
) ON [PRIMARY]
GO
