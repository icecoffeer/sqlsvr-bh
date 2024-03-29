CREATE TABLE [dbo].[SORTNAME]
(
[ACODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ENGNAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SNAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LVL] [int] NOT NULL,
[MAXGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__SORTNAME__MAXGP__539AA710] DEFAULT (100),
[MINGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__SORTNAME__MINGP__548ECB49] DEFAULT (0),
[LMODDATE] [datetime] NOT NULL CONSTRAINT [DF__SORTNAME__LMODDA__5582EF82] DEFAULT (getdate()),
[LMODOPID] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__SORTNAME__LMODOP__567713BB] DEFAULT ('未知[-]'),
[MAXQTY] [int] NOT NULL CONSTRAINT [DF__SORTNAME__MAXQTY__576B37F4] DEFAULT ((-1)),
[SORTTARGET1] [money] NOT NULL CONSTRAINT [DF__SORTNAME__SORTTA__54A63BE7] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SORTNAME] ADD CONSTRAINT [PK__SORTNAME__585F5C2D] PRIMARY KEY CLUSTERED  ([ACODE], [SCODE]) ON [PRIMARY]
GO
