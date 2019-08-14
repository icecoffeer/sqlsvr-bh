CREATE TABLE [dbo].[passwordChangeLog]
(
[id] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[employeeGid] [int] NOT NULL,
[operGid] [int] NOT NULL,
[lastmodified] [datetime] NOT NULL,
[remark] [varchar] (60) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[passwordChangeLog] ADD CONSTRAINT [PK__password__3213E83F1B4930BA] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
