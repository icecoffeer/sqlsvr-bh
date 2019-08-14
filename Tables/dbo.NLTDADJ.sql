CREATE TABLE [dbo].[NLTDADJ]
(
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NLTDADJ__FILDATE__0C484930] DEFAULT (getdate()),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__NLTDADJ__CHECKER__0D3C6D69] DEFAULT (1),
[ATYPE] [int] NOT NULL CONSTRAINT [DF__NLTDADJ__ATYPE__0E3091A2] DEFAULT (1),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NLTDADJ__RECCNT__0F24B5DB] DEFAULT (0),
[LAUNCH] [datetime] NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__NLTDADJ__SRC__1018DA14] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[RCV] [int] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NSTAT] [smallint] NOT NULL CONSTRAINT [DF__NLTDADJ__NSTAT__110CFE4D] DEFAULT (0),
[TYPE] [smallint] NOT NULL,
[RCVTIME] [datetime] NULL,
[FILLER] [int] NOT NULL CONSTRAINT [DF__NLTDADJ__FILLER__2BCD782F] DEFAULT (1),
[KEEPATYPE] [int] NOT NULL CONSTRAINT [DF__NLTDADJ__KEEPATY__1C76F15D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NLTDADJ] ADD CONSTRAINT [PK__NLTDADJ__0B5424F7] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
