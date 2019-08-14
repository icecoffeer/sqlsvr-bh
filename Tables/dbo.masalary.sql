CREATE TABLE [dbo].[masalary]
(
[asettleno] [int] NOT NULL,
[yy] [int] NOT NULL,
[mm] [int] NOT NULL,
[dept] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[xs] [decimal] (24, 2) NOT NULL,
[ml] [decimal] (24, 2) NOT NULL,
[adj] [decimal] (24, 2) NOT NULL,
[pfml] [decimal] (24, 2) NOT NULL,
[st] [decimal] (24, 2) NOT NULL,
[mle] [decimal] (24, 2) NOT NULL,
[qsmle] [decimal] (24, 2) NOT NULL,
[name] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[hp] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[planp] [decimal] (24, 2) NOT NULL,
[wcbl] [decimal] (24, 2) NOT NULL,
[yjs] [decimal] (24, 2) NOT NULL,
[jj] [decimal] (24, 2) NOT NULL
) ON [PRIMARY]
GO
