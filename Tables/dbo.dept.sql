CREATE TABLE [dbo].[dept]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[LAYER] [char] (5) COLLATE Chinese_PRC_CI_AS NULL,
[Note] [varchar] (256) COLLATE Chinese_PRC_CI_AS NULL,
[ParentCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Depth] [int] NOT NULL CONSTRAINT [DF__Dept__Depth__0BAAC160] DEFAULT (0),
[oldCode] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[oldParentCode] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__dept__LSTUPDTIME__131DFF0D] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dept] ADD CONSTRAINT [PK_dept] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
