CREATE TABLE [dbo].[SORT]
(
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (36) COLLATE Chinese_PRC_CI_AS NULL,
[GDCOUNT] [int] NOT NULL CONSTRAINT [DF__sort__GDCOUNT__7BF11A7F] DEFAULT ((-1)),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__SORT__LSTUPDTIME__14122346] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[SORT_DLT] on [dbo].[SORT] for delete as
begin
  if exists (select * from deleted where CODE = '-')
  begin
    raiserror('不能删除系统设定的类别[-]', 16, 1)
    return
  end
end
GO
ALTER TABLE [dbo].[SORT] ADD CONSTRAINT [PK__SORT__1DD065E0] PRIMARY KEY CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
