CREATE TABLE [dbo].[t_z_code]
(
[sxcode] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[sxgid] [int] NOT NULL,
[zbcode] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[zbgid] [int] NOT NULL,
[zxcode] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[zxgid] [int] NOT NULL,
[gccode] [nvarchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[gcgid] [int] NOT NULL
) ON [PRIMARY]
GO
