CREATE TABLE [dbo].[netlog]
(
[Adate] [datetime] NOT NULL,
[storecode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[message] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
