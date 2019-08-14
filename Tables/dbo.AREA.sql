CREATE TABLE [dbo].[AREA]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[AREA_DLT] ON [dbo].[AREA] FOR DELETE AS
begin
  if (select CODE from deleted) = '-'
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
    return
  end
  if exists (select * from STORE where AREA in (select CODE from deleted))
  begin
    rollback transaction
    raiserror('被删除的区域内含有门店，不能删除', 16, 1)
    return
  end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[AREA_UPD] ON [dbo].[AREA] FOR UPDATE AS
begin
  declare @old_area char(10), @new_area char(10)
  if @@rowcount > 1
  begin
    rollback transaction
    raiserror('一次只能修改一个区域', 16, 1)
    return
  end
  select @old_area = CODE from deleted
  select @new_area = CODE from inserted
  update STORE set AREA = @new_area where AREA = @old_area
end
GO
ALTER TABLE [dbo].[AREA] ADD CONSTRAINT [PK__AREA__10E07F16] PRIMARY KEY CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
