CREATE TABLE [dbo].[paychktrack]
(
[gentime] [datetime] NULL,
[actions] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[gdgid] [int] NULL,
[msg] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL,
[note] [varchar] (60) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
