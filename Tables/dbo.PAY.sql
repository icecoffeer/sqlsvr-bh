CREATE TABLE [dbo].[PAY]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NULL,
[FILDATE] [datetime] NULL,
[FILLER] [int] NULL,
[CHECKER] [int] NULL,
[WRH] [int] NULL,
[BILLTO] [int] NULL,
[AMT] [money] NULL,
[STAT] [smallint] NULL,
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[FROMCLS] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[FROMNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PYTOTAL] [money] NULL CONSTRAINT [DF__PAY__PYTOTAL__6DAD1CC9] DEFAULT (0),
[PRNTIME] [datetime] NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__PAY__PSR__3F52EBEA] DEFAULT (1),
[chktag] [smallint] NOT NULL CONSTRAINT [DF_PAY_chktag] DEFAULT (0),
[OCRDATE] [datetime] NULL,
[TAXRATELMT] [money] NULL,
[DEPT] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[CLECENT] [int] NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__PAY__SRC__44E5A0C1] DEFAULT (0),
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLEDEPT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAY] WITH NOCHECK ADD CONSTRAINT [PAY_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[PAY] ADD CONSTRAINT [PK__PAY__6497E884] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[PAY] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
