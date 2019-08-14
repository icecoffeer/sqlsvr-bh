CREATE TABLE [dbo].[shengyukucun]
(
[code] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[f1] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[memo] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[qty] [money] NULL
) ON [PRIMARY]
GO
