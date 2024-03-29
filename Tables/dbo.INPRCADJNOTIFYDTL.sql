CREATE TABLE [dbo].[INPRCADJNOTIFYDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[DEFPRC] [decimal] (24, 4) NULL,
[DIFFPRC] [decimal] (24, 4) NULL,
[PLANQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__INPRCADJN__PLANQ__079B04B1] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[REALQTY] [decimal] (24, 4) NULL,
[REALAMT] [decimal] (24, 4) NULL,
[PAYQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__INPRCADJN__PAYQT__088F28EA] DEFAULT (0),
[PAYAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__INPRCADJN__PAYAM__09834D23] DEFAULT (0),
[OLDINPRC] [money] NOT NULL CONSTRAINT [DF__INPRCADJN__OLDIN__2F14C485] DEFAULT (0),
[OLDRTLPRC] [money] NOT NULL CONSTRAINT [DF__INPRCADJN__OLDRT__3008E8BE] DEFAULT (0),
[OLDCNTINPRC] [money] NOT NULL CONSTRAINT [DF__INPRCADJN__OLDCN__30FD0CF7] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INPRCADJNOTIFYDTL] ADD CONSTRAINT [PK__INPRCADJNOTIFYDT__0A77715C] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
