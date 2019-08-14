CREATE TABLE [dbo].[XchgAssign]
(
[ServerId] [int] NOT NULL,
[StoreCode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[StorePri] [smallint] NULL CONSTRAINT [DF__XchgAssig__Store__3965086A] DEFAULT (0),
[ENTITYCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XchgAssign] ADD CONSTRAINT [PK__XchgAssign__3870E431] PRIMARY KEY CLUSTERED  ([ServerId], [StoreCode]) ON [PRIMARY]
GO
