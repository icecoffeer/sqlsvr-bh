CREATE TABLE [dbo].[dept_day_out]
(
[deptcodea] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[deptnamea] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[deptcodeb] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[deptnameb] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[asettleno] [int] NOT NULL,
[adate] [datetime] NOT NULL,
[dt1] [money] NULL,
[dt5] [money] NULL,
[di1] [money] NULL,
[di5] [money] NULL
) ON [PRIMARY]
GO
