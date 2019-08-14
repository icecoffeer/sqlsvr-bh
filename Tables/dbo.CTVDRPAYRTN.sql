CREATE TABLE [dbo].[CTVDRPAYRTN]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__CTVDRPAYRT__STAT__5E1075E7] DEFAULT (0),
[FILLER] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[CHECKER] [int] NULL,
[CHKDATE] [datetime] NULL,
[OCRDATE] [datetime] NOT NULL,
[DEPT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CTVDRPAYR__TOTAL__5F049A20] DEFAULT (0),
[VDRPAYNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CTVDRPAYR__LSTUP__5FF8BE59] DEFAULT (getdate()),
[LASTMODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTVDRPAYRTN] ADD CONSTRAINT [PK__CTVDRPAYRTN__60ECE292] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CTVDRPAYRTN_VDRPAYNUM] ON [dbo].[CTVDRPAYRTN] ([VDRPAYNUM]) ON [PRIMARY]
GO
