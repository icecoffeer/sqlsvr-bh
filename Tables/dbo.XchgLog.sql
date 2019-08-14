CREATE TABLE [dbo].[XchgLog]
(
[Num] [int] NOT NULL,
[StartTime] [datetime] NULL,
[FinishTime] [datetime] NULL,
[StoreCode] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ServerId] [int] NULL,
[ProcessorId] [int] NULL,
[FinishState] [int] NULL,
[Message] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XchgLog] ADD CONSTRAINT [PK__XchgLog__3B4D50DC] PRIMARY KEY CLUSTERED  ([Num]) ON [PRIMARY]
GO
