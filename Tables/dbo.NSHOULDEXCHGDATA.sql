CREATE TABLE [dbo].[NSHOULDEXCHGDATA]
(
[SENDDATE] [datetime] NOT NULL,
[RCV] [int] NOT NULL,
[SRC] [int] NOT NULL,
[TGT] [int] NOT NULL,
[RECCNT] [int] NOT NULL,
[NTYPE] [int] NOT NULL,
[SENDTIME] [datetime] NULL,
[RECVTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSHOULDEXCHGDATA] ADD CONSTRAINT [PK__NSHOULDEXCHGDATA__0ABF281A] PRIMARY KEY CLUSTERED  ([SENDDATE], [RCV], [SRC], [TGT]) ON [PRIMARY]
GO
