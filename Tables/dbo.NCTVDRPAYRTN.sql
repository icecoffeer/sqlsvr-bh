CREATE TABLE [dbo].[NCTVDRPAYRTN]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NCTVDRPAYR__STAT__64535F22] DEFAULT (0),
[FILLER] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[CHECKER] [int] NULL,
[CHKDATE] [datetime] NULL,
[OCRDATE] [datetime] NOT NULL,
[DEPT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTVDRPAY__TOTAL__6547835B] DEFAULT (0),
[VDRPAYNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NCTVDRPAY__LSTUP__663BA794] DEFAULT (getdate()),
[LASTMODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [int] NOT NULL,
[NNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTVDRPAYRTN] ADD CONSTRAINT [PK__NCTVDRPAYRTN__672FCBCD] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
