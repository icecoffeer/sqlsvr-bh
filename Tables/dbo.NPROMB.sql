CREATE TABLE [dbo].[NPROMB]
(
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NPROMB__STAT__7A6BF21C] DEFAULT (0),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NPROMB__FILDATE__7B601655] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NPROMB__LSTUPDTI__7C543A8E] DEFAULT (getdate()),
[TOPIC] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORESCOPE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[ASTART] [datetime] NOT NULL,
[AFINISH] [datetime] NOT NULL,
[CYCLE] [datetime] NULL,
[CSTART] [datetime] NULL,
[CFINISH] [datetime] NULL,
[CSPEC] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[FRCCHK] [smallint] NOT NULL CONSTRAINT [DF__NPROMB__FRCCHK__7D485EC7] DEFAULT (0),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NPROMB__RECCNT__7E3C8300] DEFAULT (0),
[PSETTLENO] [int] NULL,
[OCRTIME] [datetime] NOT NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[QTY] [decimal] (24, 4) NULL,
[DLTPRICEPROM] [smallint] NOT NULL CONSTRAINT [DF__NPROMB__DLTPRICE__61B6E999] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPROMB] ADD CONSTRAINT [PK__NPROMB__7F30A739] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPROMB_TYPE] ON [dbo].[NPROMB] ([TYPE]) ON [PRIMARY]
GO
