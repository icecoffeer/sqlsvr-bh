CREATE TABLE [dbo].[NALCDIFF]
(
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[CLIENT] [int] NOT NULL CONSTRAINT [DF__NALCDIFF__CLIENT__19AEC7F4] DEFAULT (1),
[BILLTO] [int] NOT NULL CONSTRAINT [DF__NALCDIFF__BILLTO__1AA2EC2D] DEFAULT (1),
[WRH] [int] NULL,
[FILLER] [int] NOT NULL CONSTRAINT [DF__NALCDIFF__FILLER__1B971066] DEFAULT (1),
[FILDATE] [datetime] NOT NULL,
[REQOPER] [int] NULL,
[REQDATE] [datetime] NULL,
[CHECKER] [int] NULL,
[CHKDATE] [datetime] NULL,
[CANCELER] [int] NULL,
[CACLDATE] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NALCDIFF__LSTUPD__1C8B349F] DEFAULT (getdate()),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NALCDIFF__STAT__1D7F58D8] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[CAUSE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__NALCDIFF__CAUSE__1E737D11] DEFAULT ('不明'),
[ATTITUDE] [smallint] NOT NULL CONSTRAINT [DF__NALCDIFF__ATTITU__1F67A14A] DEFAULT (0),
[ALCFROM] [int] NOT NULL,
[GENNOTE] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL,
[GENSTAT] [smallint] NOT NULL CONSTRAINT [DF__NALCDIFF__GENSTA__205BC583] DEFAULT (1),
[NSTAT] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NALCDIFF] ADD CONSTRAINT [PK__NALCDIFF__214FE9BC] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NALCDIFF_TYPE] ON [dbo].[NALCDIFF] ([TYPE]) ON [PRIMARY]
GO