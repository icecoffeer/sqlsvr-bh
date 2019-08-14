CREATE TABLE [dbo].[CNCASHCENTER]
(
[STORE] [int] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NOT NULL,
[CASHCENTER] [int] NOT NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CNCASHCEN__CREAT__18C72761] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__CNCASHCEN__CREAT__19BB4B9A] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CNCASHCEN__LSTUP__1AAF6FD3] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CNCASHCEN__LSTUP__1BA3940C] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--本触发器根据项目需要进行个性定制
create trigger [dbo].[CC_DLT] on [dbo].[CNCASHCENTER] for delete as
begin
  select a = 1 --此语句无意义,原因是如果内容为空会报语法错
end
GO
ALTER TABLE [dbo].[CNCASHCENTER] ADD CONSTRAINT [PK__CNCASHCENTER__1C97B845] PRIMARY KEY CLUSTERED  ([STORE], [DEPT], [VENDOR]) ON [PRIMARY]
GO