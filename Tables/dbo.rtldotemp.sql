CREATE TABLE [dbo].[rtldotemp]
(
[rtlnum] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[stknum] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gdgid] [int] NOT NULL,
[alcprc] [money] NULL,
[inprc] [money] NOT NULL,
[price] [money] NULL,
[sale] [smallint] NOT NULL
) ON [PRIMARY]
GO
