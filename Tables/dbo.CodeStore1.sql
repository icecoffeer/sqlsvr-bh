CREATE TABLE [dbo].[CodeStore1]
(
[Code] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Name] [char] (12) COLLATE Chinese_PRC_CI_AS NULL,
[PreCode] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[Weight] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Area] [decimal] (8, 2) NULL
) ON [PRIMARY]
GO
