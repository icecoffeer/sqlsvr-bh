CREATE TABLE [dbo].[OVF]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[WRH] [int] NULL,
[FILDATE] [datetime] NULL CONSTRAINT [DF__OVF__FILDATE__143CDA05] DEFAULT (getdate()),
[FILLER] [int] NULL,
[CHECKER] [int] NULL,
[STAT] [smallint] NULL CONSTRAINT [DF__OVF__STAT__1530FE3E] DEFAULT (0),
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[AMTOVF] [money] NULL CONSTRAINT [DF__OVF__AMTOVF__16252277] DEFAULT (0),
[RECCNT] [int] NULL CONSTRAINT [DF__OVF__RECCNT__171946B0] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PRNTIME] [datetime] NULL,
[CAUSE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[FSOURSE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[FSOURSENUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OVF] WITH NOCHECK ADD CONSTRAINT [OVF_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[OVF] ADD CONSTRAINT [PK__OVF__62AFA012] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[OVF] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
