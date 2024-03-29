CREATE TABLE [dbo].[NDSPREG]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NDSPREG__FILDATE__27FA8546] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__NDSPREG__FILLER__28EEA97F] DEFAULT (1),
[INVNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ACPTIME] [datetime] NULL,
[ACPEMP] [int] NULL,
[OPER] [int] NULL,
[RECCNT] [int] NOT NULL,
[DSPNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NDSPREG] ADD CONSTRAINT [PK__NDSPREG__25A691D2] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
