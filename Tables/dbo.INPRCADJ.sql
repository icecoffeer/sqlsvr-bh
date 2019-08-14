CREATE TABLE [dbo].[INPRCADJ]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[ADJDATE] [datetime] NULL CONSTRAINT [DF__INPRCADJ__ADJDAT__714A3A31] DEFAULT (getdate()),
[INBILL] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INLINE] [smallint] NULL,
[SUBWRH] [int] NULL,
[VENDOR] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[NEWPRC] [money] NOT NULL,
[INADJAMT] [money] NOT NULL,
[INVADJAMT] [money] NOT NULL,
[OUTADJAMT] [money] NOT NULL,
[ALCADJAMT] [money] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__INPRCADJ__FILDAT__723E5E6A] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__INPRCADJ__FILLER__733282A3] DEFAULT (1),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__INPRCADJ__STAT__7426A6DC] DEFAULT (0),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__INPRCADJ__CHECKE__751ACB15] DEFAULT (1),
[CHKDATE] [datetime] NULL,
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__INPRCADJ__PSR__760EEF4E] DEFAULT (1),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INPRCADJ] WITH NOCHECK ADD CONSTRAINT [INPRCADJ_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[INPRCADJ] ADD CONSTRAINT [PK__INPRCADJ__740F363E] PRIMARY KEY CLUSTERED  ([CLS], [NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO