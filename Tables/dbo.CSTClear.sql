CREATE TABLE [dbo].[CSTClear]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[FILLER] [int] NOT NULL,
[CSTGID] [int] NOT NULL,
[IsUpd] [smallint] NOT NULL CONSTRAINT [DF__CSTClear__IsUpd__118CEC91] DEFAULT (0),
[IsDel] [smallint] NOT NULL CONSTRAINT [DF__CSTClear__IsDel__128110CA] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSTClear] WITH NOCHECK ADD CONSTRAINT [CSTClear_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[CSTClear] ADD CONSTRAINT [PK__CSTClear__361203C5] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
