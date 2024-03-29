CREATE TABLE [dbo].[XSRVTASK]
(
[TID] [int] NOT NULL,
[STORECODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SCHUNIT] [varchar] (4) COLLATE Chinese_PRC_CI_AS NULL,
[SCHINDEX] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SCHITIME] [varchar] (8) COLLATE Chinese_PRC_CI_AS NULL,
[NEXTTIME] [datetime] NULL,
[STIME] [datetime] NULL,
[XSRVTASKETIME] [datetime] NULL,
[MSG] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[EXGTYPE] [varchar] (6) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__XSRVTASK__EXGTYP__401205F9] DEFAULT ('FTP'),
[XChgACT] [int] NULL CONSTRAINT [DF__XSRVTASK__XChgAC__41062A32] DEFAULT (5),
[status] [varchar] (6) COLLATE Chinese_PRC_CI_AS NULL,
[BHASDTL] [int] NOT NULL CONSTRAINT [DF__XSRVTASK__BHASDT__41FA4E6B] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XSRVTASK] ADD CONSTRAINT [PK__XSRVTASK__3F1DE1C0] PRIMARY KEY CLUSTERED  ([TID]) ON [PRIMARY]
GO
