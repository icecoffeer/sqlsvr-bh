CREATE TABLE [dbo].[NCARD]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[GID] [int] NOT NULL,
[CODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__NCARD__CREATEDAT__60FDF878] DEFAULT (getdate()),
[VALIDDATE] [datetime] NOT NULL,
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[FRCUPD] [smallint] NOT NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[BALANCE] [money] NULL,
[CSTGID] [int] NOT NULL CONSTRAINT [DF__NCARD__CSTGID__61F21CB1] DEFAULT (1),
[CARDTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SALEDATE] [datetime] NOT NULL CONSTRAINT [DF__NCARD__SALEDATE__62E640EA] DEFAULT (getdate()),
[STATE] [smallint] NOT NULL CONSTRAINT [DF__NCARD__STATE__63DA6523] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCARD] ADD CONSTRAINT [PK__NCARD__184C96B4] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO