CREATE TABLE [dbo].[NPRMOFFSET]
(
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VDRGID] [int] NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILLER] [int] NOT NULL CONSTRAINT [DF__NPRMOFFSE__FILLE__12CFED97] DEFAULT (1),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NPRMOFFSE__FILDA__13C411D0] DEFAULT (getdate()),
[CHECKER] [int] NULL,
[CHKDATE] [datetime] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NPRMOFFSE__RECCN__14B83609] DEFAULT (0),
[STAT] [int] NOT NULL CONSTRAINT [DF__NPRMOFFSET__STAT__15AC5A42] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LAUNCH] [datetime] NULL,
[NSTAT] [smallint] NOT NULL CONSTRAINT [DF__NPRMOFFSE__NSTAT__16A07E7B] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NOT NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[LSTUPDTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL CONSTRAINT [DF__NPRMOFFSE__FRCCH__1794A2B4] DEFAULT (0),
[OFFSETTYPE] [int] NOT NULL CONSTRAINT [DF__NPRMOFFSE__OFFSE__1888C6ED] DEFAULT (0),
[OFFSETCALCTYPE] [int] NULL,
[TOTAL] [decimal] (24, 4) NULL,
[AMOUNT] [decimal] (24, 4) NULL,
[TAX] [decimal] (24, 4) NULL,
[BILLTO] [int] NOT NULL,
[GATHERINGMODE] [int] NOT NULL CONSTRAINT [DF__NPRMOFFSE__GATHE__197CEB26] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPRMOFFSET] ADD CONSTRAINT [PK__NPRMOFFSET__1A710F5F] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPRMOFFSET_TYPE] ON [dbo].[NPRMOFFSET] ([TYPE]) ON [PRIMARY]
GO