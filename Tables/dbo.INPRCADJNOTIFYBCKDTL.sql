CREATE TABLE [dbo].[INPRCADJNOTIFYBCKDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[DEFPRC] [decimal] (24, 4) NULL,
[DIFFPRC] [decimal] (24, 4) NULL,
[PLANQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__INPRCADJN__PLANQ__0C5FB9CE] DEFAULT (0),
[QTY] [decimal] (24, 4) NULL,
[OLDPRC] [decimal] (24, 4) NULL,
[NEWPRC] [decimal] (24, 4) NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__INPRCADJNO__STAT__0D53DE07] DEFAULT (0),
[AMT] [decimal] (24, 4) NULL,
[PAYQTY] [money] NOT NULL CONSTRAINT [DF__INPRCADJN__PAYQT__2D2C7C13] DEFAULT (0),
[PAYAMT] [money] NOT NULL CONSTRAINT [DF__INPRCADJN__PAYAM__2E20A04C] DEFAULT (0),
[CNTAMT] [money] NULL,
[CNTPRC] [money] NULL,
[LACTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INPRCADJNOTIFYBCKDTL] ADD CONSTRAINT [PK__INPRCADJNOTIFYBC__0E480240] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
