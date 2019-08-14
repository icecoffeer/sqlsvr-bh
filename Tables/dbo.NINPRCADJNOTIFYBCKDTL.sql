CREATE TABLE [dbo].[NINPRCADJNOTIFYBCKDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[DEFPRC] [decimal] (24, 4) NULL,
[DIFFPRC] [decimal] (24, 4) NULL,
[PLANQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NINPRCADJ__PLANQ__19B9B4EC] DEFAULT (0),
[QTY] [decimal] (24, 4) NULL,
[OLDPRC] [decimal] (24, 4) NULL,
[NEWPRC] [decimal] (24, 4) NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NINPRCADJN__STAT__1AADD925] DEFAULT (0),
[AMT] [decimal] (24, 4) NULL,
[CNTAMT] [money] NULL,
[CNTPRC] [money] NULL,
[LACTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINPRCADJNOTIFYBCKDTL] ADD CONSTRAINT [PK__NINPRCADJNOTIFYB__1BA1FD5E] PRIMARY KEY CLUSTERED  ([LINE], [SRC], [ID]) ON [PRIMARY]
GO
