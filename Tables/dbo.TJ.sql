CREATE TABLE [dbo].[TJ]
(
[Type] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Code] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Name] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Remark] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[QtyName] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[AmtName] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[QtyUnit] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__TJ__QtyUnit__13193B03] DEFAULT (1),
[AmtUnit] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__TJ__AmtUnit__140D5F3C] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TJ] ADD CONSTRAINT [PK__TJ__15018375] PRIMARY KEY CLUSTERED  ([Type], [Code]) ON [PRIMARY]
GO
