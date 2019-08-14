CREATE TABLE [dbo].[NMXFDMD]
(
[ID] [int] NOT NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NMXFDMD__STAT__6AECE4C6] DEFAULT (0),
[FROMSTORE] [int] NOT NULL,
[TOSTORE] [int] NOT NULL,
[XCHGSTORE] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NMXFDMD__FILDATE__6BE108FF] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NMXFDMD__FILLER__6CD52D38] DEFAULT ('未知[-]'),
[DMDDATE] [datetime] NULL,
[DMDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NULL,
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[SRCNUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[EXPDATE] [datetime] NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[FROMTOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMXFDMD__FROMTOT__6DC95171] DEFAULT (0),
[FROMTAX] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMXFDMD__FROMTAX__6EBD75AA] DEFAULT (0),
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NMXFDMD] ADD CONSTRAINT [PK__NMXFDMD__6FB199E3] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NMXFDMD_TYPE] ON [dbo].[NMXFDMD] ([TYPE]) ON [PRIMARY]
GO
