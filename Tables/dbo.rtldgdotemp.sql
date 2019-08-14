CREATE TABLE [dbo].[rtldgdotemp]
(
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fildate] [datetime] NOT NULL,
[gdgid] [int] NOT NULL,
[inprc] [money] NOT NULL,
[qty] [money] NOT NULL,
[cost] [money] NOT NULL
) ON [PRIMARY]
GO
