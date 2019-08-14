CREATE TABLE [dbo].[RCP]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[FILDATE] [datetime] NULL,
[FILLER] [int] NULL,
[CHECKER] [int] NULL,
[WRH] [int] NULL,
[CLIENT] [int] NULL,
[AMT] [money] NULL,
[STAT] [smallint] NULL,
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OUTNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PRNTIME] [datetime] NULL,
[OCRDATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RCP] WITH NOCHECK ADD CONSTRAINT [RCP_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[RCP] ADD CONSTRAINT [PK__RCP__08D548FA] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[RCP] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
