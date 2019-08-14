CREATE TABLE [dbo].[gdrate]
(
[gdgid] [int] NULL,
[billto] [int] NULL,
[sale] [int] NULL,
[rate] [money] NULL,
[payrate2] [money] NULL,
[brand] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dept] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
