CREATE TABLE [dbo].[spkc]
(
[spid] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fcid] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[bz] [varchar] (2) COLLATE Chinese_PRC_CI_AS NOT NULL,
[sl] [float] NOT NULL,
[je] [float] NOT NULL,
[xssl] [float] NULL,
[xsje] [float] NULL,
[jssl] [float] NULL,
[jsje] [float] NULL,
[jx] [varchar] (1) COLLATE Chinese_PRC_CI_AS NOT NULL,
[jj] [float] NOT NULL,
[xj] [float] NOT NULL,
[thsl] [float] NULL,
[thje] [float] NULL,
[pssl] [float] NULL
) ON [PRIMARY]
GO
