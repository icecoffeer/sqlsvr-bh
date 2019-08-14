CREATE TABLE [dbo].[XchgServer]
(
[ServerId] [int] NOT NULL,
[ServerName] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ProcessorCount] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[XchgServer] ADD CONSTRAINT [PK__XchgServer__30CFC269] PRIMARY KEY CLUSTERED  ([ServerId]) ON [PRIMARY]
GO
