CREATE TABLE [dbo].[XchgTask]
(
[StoreCode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TID] [int] NOT NULL CONSTRAINT [DF__XchgTask__TID__33AC2F14] DEFAULT ((-1)),
[ServerId] [int] NULL,
[TaskState] [smallint] NOT NULL CONSTRAINT [DF__XchgTask__TaskSt__34A0534D] DEFAULT (0),
[act] [smallint] NOT NULL CONSTRAINT [DF__XchgTask__act__35947786] DEFAULT (5),
[ChgType] [smallint] NOT NULL CONSTRAINT [DF__XchgTask__ChgTyp__36889BBF] DEFAULT (0),
[ProcessorId] [int] NULL,
[StartTime] [datetime] NULL,
[FinishTime] [datetime] NULL,
[FinishState] [int] NULL,
[Message] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XchgTask] ADD CONSTRAINT [PK__XchgTask__32B80ADB] PRIMARY KEY CLUSTERED  ([StoreCode]) ON [PRIMARY]
GO
