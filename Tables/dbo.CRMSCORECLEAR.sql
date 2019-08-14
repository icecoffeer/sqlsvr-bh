CREATE TABLE [dbo].[CRMSCORECLEAR]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__CRMSCORECL__STAT__472AAE8A] DEFAULT (0),
[COUNT] [int] NOT NULL,
[TOTALSCORE] [decimal] (24, 2) NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__CRMSCOREC__FILDA__481ED2C3] DEFAULT (getdate()),
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NULL,
[SRC] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMSCORECLEAR] ADD CONSTRAINT [PK__CRMSCORECLEAR__4912F6FC] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO