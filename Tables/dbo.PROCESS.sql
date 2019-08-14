CREATE TABLE [dbo].[PROCESS]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PSCPGID] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PROCESS__FILDATE__218E4A30] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__PROCESS__FILLER__22826E69] DEFAULT (1),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PROCESS__STAT__237692A2] DEFAULT (0),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__PROCESS__CHECKER__246AB6DB] DEFAULT (1),
[CHKDATE] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[PRECHECKER] [int] NULL,
[PRECHKDATE] [datetime] NULL,
[MULTIPLE] [money] NULL CONSTRAINT [DF__PROCESS__MULTIPL__255EDB14] DEFAULT (1),
[RAWCOST] [money] NOT NULL CONSTRAINT [DF__PROCESS__RAWCOST__2652FF4D] DEFAULT (0),
[PDTCOST] [money] NOT NULL CONSTRAINT [DF__PROCESS__PDTCOST__27472386] DEFAULT (0),
[RAWRECCNT] [int] NOT NULL,
[PDTRECCNT] [int] NOT NULL,
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROCESS] WITH NOCHECK ADD CONSTRAINT [PROCESS_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[PROCESS] ADD CONSTRAINT [PK__PROCESS__7C6F7215] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
