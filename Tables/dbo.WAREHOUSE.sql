CREATE TABLE [dbo].[WAREHOUSE]
(
[GID] [int] NOT NULL IDENTITY(1, 1),
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CHKVD] [smallint] NULL CONSTRAINT [DF__WAREHOUSE__CHKVD__0BC78F95] DEFAULT (0),
[AUTOORD] [smallint] NULL CONSTRAINT [DF__WAREHOUSE__AUTOO__0CBBB3CE] DEFAULT (0),
[ALLOWNEG] [smallint] NULL CONSTRAINT [DF__WAREHOUSE__ALLOW__0DAFD807] DEFAULT (1)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[WRH_DLT] on [dbo].[WAREHOUSE] for delete as
begin
  if exists (select * from deleted where GID = 1)
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
    return
  end
  if exists (select * from deleted where GID = (select ALCWRH from SYSTEM))
  begin
    rollback transaction
    raiserror('不能删除本店配货仓位', 16, 1)
    return
  end
  if exists (select * from deleted where GID = (select DIRALCWRH from SYSTEM))
  begin
    rollback transaction
    raiserror('不能删除本店直配仓位', 16, 1)
    return
  end
  if exists (select * from INV where WRH in (select GID from DELETED))
  begin
    rollback transaction
    raiserror('被删除的仓位尚有库存商品, 不能删除该仓位.',  16, 1)
    return
  end
  if exists (select * from GOODS where WRH in (select GID from DELETED))
  begin
    rollback transaction
    raiserror('存在缺省仓位为本仓位的商品, 不能删除该仓位.', 16, 1)
    return
  end
  if exists (select * from deleted, V_VDRYRPT where GID = BWRH)
  begin
    rollback transaction
    raiserror('要删除的仓位存在未结供应商，不能删除这些仓位.', 16, 1)
    return
  end
  if exists (select * from deleted, V_CSTYRPT where GID = BWRH)
  begin
    rollback transaction
    raiserror('要删除的仓位存在未结客户，不能删除这些仓位.', 16, 1)
    return
  end
  if exists (select * from deleted, store where deleted.GID = store.gid)
  begin
    rollback transaction
    raiserror('要删除的仓位存在对应门店，不能删除这些仓位.', 16, 1)
    return
  end
  delete from INV from deleted where WRH = GID
  delete from VDRGD from deleted where WRH = GID
  delete from WRHEMP from deleted where WRHGID = GID
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[WRH_INS] on [dbo].[WAREHOUSE] for insert as
begin
  insert into WAREHOUSEH
    select * from INSERTED
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[WRH_UPD] on [dbo].[WAREHOUSE] for update as
begin
  delete from WAREHOUSEH
    from DELETED
    where WAREHOUSEH.GID = DELETED.GID
  insert into WAREHOUSEH
    select * from INSERTED
end

GO
ALTER TABLE [dbo].[WAREHOUSE] ADD CONSTRAINT [PK__WAREHOUSE__0AD36B5C] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WAREHOUSE] ADD CONSTRAINT [UQ__WAREHOUSE__09DF4723] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
