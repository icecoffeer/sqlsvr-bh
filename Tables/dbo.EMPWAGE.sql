CREATE TABLE [dbo].[EMPWAGE]
(
[settleno] [int] NULL,
[gid] [int] NULL,
[dept] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[bishu] [money] NULL CONSTRAINT [DF__EMPWAGE__bishu__02D32238] DEFAULT (0),
[realamt] [money] NULL CONSTRAINT [DF__EMPWAGE__realamt__03C74671] DEFAULT (0),
[inramt] [money] NULL CONSTRAINT [DF__EMPWAGE__inramt__04BB6AAA] DEFAULT (0),
[jj] [money] NULL CONSTRAINT [DF__EMPWAGE__jj__05AF8EE3] DEFAULT (0),
[de] [money] NULL CONSTRAINT [DF__EMPWAGE__de__06A3B31C] DEFAULT (0),
[gzd] [money] NULL CONSTRAINT [DF__EMPWAGE__gzd__0797D755] DEFAULT (0),
[lx] [char] (6) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__EMPWAGE__lx__088BFB8E] DEFAULT ('营业员')
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [jjff_sdgl] ON [dbo].[EMPWAGE] ([settleno], [dept], [gid], [lx]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
