CREATE TABLE [dbo].[CurrentEmp]
(
[id] [int] NOT NULL,
[Empgid] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CurrentEmp] ADD CONSTRAINT [PK__CurrentEmp__34AF38F8] PRIMARY KEY CLUSTERED  ([id], [Empgid]) ON [PRIMARY]
GO
