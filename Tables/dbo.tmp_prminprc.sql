CREATE TABLE [dbo].[tmp_prminprc]
(
[gid] [int] NOT NULL,
[code] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[prminprc] [money] NULL
) ON [PRIMARY]
GO
