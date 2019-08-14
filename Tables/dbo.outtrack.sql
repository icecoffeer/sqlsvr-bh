CREATE TABLE [dbo].[outtrack]
(
[gentime] [datetime] NULL CONSTRAINT [DF__outtrack__gentim__04AB201B] DEFAULT (getdate()),
[gdgid] [int] NULL,
[sale] [int] NULL,
[inxs] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[bslrgid] [int] NULL,
[bvdrgid] [int] NULL,
[bctgid] [int] NULL,
[dq] [money] NULL,
[dt] [money] NULL,
[di] [money] NULL,
[dr] [money] NULL,
[param] [int] NULL
) ON [PRIMARY]
GO
