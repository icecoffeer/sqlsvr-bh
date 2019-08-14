CREATE TABLE [dbo].[VENDOR]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SHORTNAME] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [char] (60) COLLATE Chinese_PRC_CI_AS NULL,
[TAXNO] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[ACCOUNTNO] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FAX] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ZIP] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[TELE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__VENDOR__CREATEDA__72C7A2F8] DEFAULT (getdate()),
[PROPERTY] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLEACCOUNT] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[PAYTERM] [smallint] NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LAWREP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CONTACTOR] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CTRPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CTRBP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__VENDOR__SRC__73BBC731] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__VENDOR__LSTUPDTI__74AFEB6A] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__VENDOR__FILLER__75A40FA3] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__VENDOR__MODIFIER__769833DC] DEFAULT (1),
[KEEPAMT] [money] NOT NULL CONSTRAINT [DF__VENDOR__KEEPAMT__778C5815] DEFAULT (0),
[TAXTYPE] [smallint] NOT NULL CONSTRAINT [DF__VENDOR__TAXTYPE__78807C4E] DEFAULT (1),
[EMAILADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[WWWADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CDTRATE] [money] NULL CONSTRAINT [DF__VENDOR__CDTRATE__7974A087] DEFAULT (0),
[ADFEE] [money] NULL CONSTRAINT [DF__VENDOR__ADFEE__7A68C4C0] DEFAULT (0),
[PRMFEE] [money] NULL CONSTRAINT [DF__VENDOR__PRMFEE__7B5CE8F9] DEFAULT (0),
[INVCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[REGFUND] [money] NULL,
[CTRIDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[VTM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OTHERSALEAREA] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RTLPRCSTYLE] [smallint] NOT NULL CONSTRAINT [DF__VENDOR__RTLPRCST__7B12D036] DEFAULT (0),
[RTLPRCRANGE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTER] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTERAREA] [money] NULL,
[VAREA] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[OUTTERWRHAREA] [money] NULL,
[TGTSALEAMT] [money] NULL,
[LWTSALEAMT] [money] NULL,
[DRAWRATE] [money] NULL,
[EQPUSEAMT] [money] NULL,
[ASSISTANTS] [int] NULL,
[CLOTHUSES] [int] NULL,
[ASTSALARY] [money] NULL,
[CREDITS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CTRBEGIN] [datetime] NULL,
[CTREND] [datetime] NULL,
[SIGNDATE] [datetime] NULL,
[hizjde] [money] NOT NULL CONSTRAINT [DF__vendor__hizjde__2AE1DEE9] DEFAULT (0),
[lowzjde] [money] NOT NULL CONSTRAINT [DF__vendor__lowzjde__2BD60322] DEFAULT (0),
[days] [int] NOT NULL CONSTRAINT [DF__vendor__days__0432F173] DEFAULT (0),
[PAYCLS] [smallint] NULL CONSTRAINT [DF__VENDOR__PAYCLS__4A59BEEB] DEFAULT (2),
[MVDR] [int] NOT NULL CONSTRAINT [DF__VENDOR__MVDR__66C0F36F] DEFAULT (1),
[ISUSETOKEN] [smallint] NOT NULL CONSTRAINT [DF__vendor__ISUSETOK__4A10717F] DEFAULT (0),
[SAFEAMT] [money] NULL CONSTRAINT [DF__VENDOR__SAFEAMT__396FF562] DEFAULT (0),
[PAYLIMITED] [char] (2) COLLATE Chinese_PRC_CI_AS NULL,
[SendArea] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PayType] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[upay] [int] NOT NULL CONSTRAINT [DF_VENDOR_upay] DEFAULT (0),
[UPCTRL] [int] NOT NULL CONSTRAINT [DF__VENDOR__UPCTRL__6ABECEE1] DEFAULT (0),
[SendType] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SendLocation] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[BckCycleType] [int] NULL CONSTRAINT [DF__vendor__BckCycle__7EBBA5ED] DEFAULT (0),
[BckBgnMon] [int] NULL,
[BckBgnDays] [int] NULL,
[BckBgnAmt] [money] NULL,
[BckExpRate] [money] NULL,
[BckExpDays] [int] NULL,
[BckLmt] [int] NOT NULL CONSTRAINT [DF__vendor__BckLmt__7FAFCA26] DEFAULT (0),
[MinDlvQty] [money] NULL,
[MinDlvAmt] [money] NULL,
[OrderLmt] [decimal] (24, 2) NULL,
[ISGENEIVC] [smallint] NOT NULL CONSTRAINT [DF__VENDOR__ISGENEIV__72D12B0C] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_DLT] on [dbo].[VENDOR] for delete as
begin
  if exists (select * from deleted where GID = 1)
  begin 
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
    return
  end

  if exists (select 1 from VENDOR, deleted where VENDOR.MVDR = deleted.GID)
  begin 
    rollback transaction
    raiserror('本供应商为其他供应商的主供应商，不能删除', 16, 1)
    return
  end                                       --2002-08-08 Jianweicheng

  if exists (
    select 1 from deleted, V_VDRYRPT where deleted.GID = V_VDRYRPT.BVDRGID
    group by BVDRGID, BWRH having sum(NPTL) <> 0
  ) begin
    rollback transaction
    raiserror('不能删除未结供应商', 16, 1)
    return
  end
  if exists ( select * from GOODS where BILLTO in
    (select GID from deleted)
  ) begin
    rollback transaction
    raiserror('存在默认供应商为要删除供应商的商品，不能删除这些商品。', 16, 1)
    return
  end
  if exists ( select * from STORE where GID in
    (select GID from deleted)
  ) begin
    rollback transaction
    raiserror('不能删除存在对应门店的供应商', 16, 1)
    return
  end
  delete from VDRGD from DELETED where VDRGD.VDRGID = deleted.GID
  delete from VDRXLATE from deleted where LGID = GID
  
--2002-05-16  
  if (select singlevdr from system) = 2 
    delete from VDRGD2 from DELETED where VDRGD2.VDRGID = deleted.GID
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_DLT_BAK] on [dbo].[VENDOR] for delete as
begin
  if exists (select * from deleted where GID = 1)
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
    return
  end
  if exists (
    select * from deleted, V_VDRYRPT where deleted.GID = V_VDRYRPT.BVDRGID
  ) begin
    rollback transaction
    raiserror('不能删除未结供应商', 16, 1)
    return
  end
  if exists ( select * from GOODS where BILLTO in
    (select GID from deleted)
  ) begin
    rollback transaction
    raiserror('存在默认供应商为要删除供应商的商品，不能删除这些商品。', 16, 1)
    return
  end
  delete from VDRGD from DELETED where VDRGD.VDRGID = deleted.GID
  delete from VDRXLATE from deleted where LGID = GID
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_DLT_OL] on [dbo].[VENDOR] for delete as
begin
  Declare
    @vOper Varchar(60),
    @vGid Int

  --取得当前登录用户
  Exec PFA_SYS_GETCUROPERNAMECODE @vOper Output

  Declare c_Del_Ol Cursor Local For
    Select Gid From Deleted

  Open c_Del_Ol
  Fetch Next From c_Del_Ol into @vGid
  While @@Fetch_Status = 0
  Begin
    --插入一条日志记录
    Exec BasicInfoChg_AddLog 'Vendor', 'Gid', @vGid, 'Del', @vOper

    Fetch Next From c_Del_Ol into @vGid
  End
  Close c_Del_Ol
  Deallocate c_Del_Ol
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_INS] on [dbo].[VENDOR] for insert as
begin
  insert into VENDORH
    select * from INSERTED
  insert into VDRXLATE (NGID,LGID) select GID,GID from inserted

--Added by Zhuhaohui 2007.12.17 新增供应商消息提醒

  declare @gid int,
          @code varchar(13),
          @name varchar(50),
          @createdate datetime
  declare @xml_gid varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200)
  declare @xml_map_dict varchar(2100),
          @xml_map_prompt varchar(2100)
  declare @usergid int,
          @usercode varchar(10),
          @username varchar(20)
  declare @return varchar(255)
  declare c_ins CURSOR for
    select GID, RTRIM(CODE), RTRIM(Name), Filler, CreateDate from inserted

  open c_ins
  fetch next from c_ins into @gid, @code, @name, @usergid, @createdate
  while @@fetch_status = 0
  begin
  
    --触发的数据字典dict
    execute PFA_SERIALIZEXML_SETINTEGER 'GID', @gid, @xml_gid output
    set @xml_map_dict=@xml_gid
  
    --模块参数  
    execute PFA_GET_OPERINFO_BYGID @usergid output, @usercode output, @Username output
    set @xml_title = '用户[' + @username + ']新增了供应商[' + @name + '-' + @code + ']'
    execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
    execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 21, @xml_moduleNo output
    execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output
    execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowVendor', @xml_procName output
    set @xml_params = Convert(varchar, @gid)
    execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output
    set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params
  
    --插入触发记录
    execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_VENDOR', '供应商新增提醒', @xml_map_dict, @xml_map_prompt, @createdate, @usergid, @usercode, @username, @return output
  
    --下一条
    fetch next from c_ins into @gid, @code, @name, @usergid, @createdate
  end
  close c_ins
  deallocate c_ins

--end of 新增商品消息提醒

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_INS_OL] on [dbo].[VENDOR] for insert as
begin
  Declare
    @vOper Varchar(60),
    @vGid Int

  --取得当前登录用户
  Exec PFA_SYS_GETCUROPERNAMECODE @vOper Output

  Declare c_Ins_Ol Cursor Local For
    Select Gid From Inserted

  Open c_Ins_Ol
  Fetch Next From c_Ins_Ol into @vGid
  While @@Fetch_Status = 0
  Begin
    --插入一条日志记录
    Exec BasicInfoChg_AddLog 'Vendor', 'Gid', @vGid, 'Ins', @vOper

    Fetch Next From c_Ins_Ol into @vGid
  End
  Close c_Ins_Ol
  Deallocate c_Ins_Ol
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_UPD] on [dbo].[VENDOR] for update as
begin
  delete from VENDORH from DELETED
    where VENDORH.GID = DELETED.GID
  insert into VENDORH
    select * from INSERTED
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[VDR_UPD_OL] on [dbo].[VENDOR] for update as
begin
  Declare
    @vOper Varchar(60),
    @vGid Int

  --取得当前登录用户
  Exec PFA_SYS_GETCUROPERNAMECODE @vOper Output

  Declare c_Upd_Ol Cursor Local For
    Select Gid From Inserted

  Open c_Upd_Ol
  Fetch Next From c_Upd_Ol into @vGid
  While @@Fetch_Status = 0
  Begin
    --插入一条日志记录
    Exec BasicInfoChg_AddLog 'Vendor', 'Gid', @vGid, 'Upd', @vOper

    Fetch Next From c_Upd_Ol into @vGid
  End
  Close c_Upd_Ol
  Deallocate c_Upd_Ol
end
GO
ALTER TABLE [dbo].[VENDOR] ADD CONSTRAINT [PK__VENDOR__675524F5] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VENDOR] ADD CONSTRAINT [UQ__VENDOR__3F3159AB] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
