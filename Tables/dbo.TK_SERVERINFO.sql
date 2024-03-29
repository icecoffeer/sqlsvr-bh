CREATE TABLE [dbo].[TK_SERVERINFO]
(
[ID] [int] NOT NULL,
[ADTIME] [datetime] NOT NULL CONSTRAINT [DF__TK_SERVER__ADTIM__2CB518C2] DEFAULT (getdate()),
[HDDIFF] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__HDDIF__2DA93CFB] DEFAULT (0),
[TIMEWINDOW] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__TIMEW__2E9D6134] DEFAULT (120),
[LIMITTIME] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__LIMIT__2F91856D] DEFAULT (2),
[ISLIMIT] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__ISLIM__3085A9A6] DEFAULT (1),
[LIMITTIMES] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__LIMIT__3179CDDF] DEFAULT (3),
[LOCKTIME] [money] NOT NULL CONSTRAINT [DF__TK_SERVER__LOCKT__326DF218] DEFAULT (0.5),
[LOCKED] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__LOCKE__33621651] DEFAULT (0),
[SERVICEDATE] [money] NOT NULL CONSTRAINT [DF__TK_SERVER__SERVI__34563A8A] DEFAULT (3),
[ADJUSTITV] [int] NOT NULL CONSTRAINT [DF__TK_SERVER__ADJUS__354A5EC3] DEFAULT (30)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TK_SERVERINFO] ADD CONSTRAINT [PK__TK_SERVERINFO__2BC0F489] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
