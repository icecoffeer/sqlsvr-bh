CREATE TABLE [dbo].[rtlrepair]
(
[adate] [datetime] NULL,
[rtlnum] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[stkinnum] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[line] [int] NULL,
[wrh] [int] NULL,
[gdgid] [int] NULL,
[qty] [money] NULL,
[rtlinprc] [money] NULL,
[stkininprc] [money] NULL,
[newinprc] [money] NULL
) ON [PRIMARY]
GO
