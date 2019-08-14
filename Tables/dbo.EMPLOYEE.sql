CREATE TABLE [dbo].[EMPLOYEE]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[IDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[WORKTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[DISCOUNT] [money] NOT NULL CONSTRAINT [DF__EMPLOYEE__DISCOU__7D7A3B95] DEFAULT (100),
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__EMPLOYEE__CREATE__7E6E5FCE] DEFAULT (getdate()),
[PASSWORD] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[LOCALRIGHT] [text] COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__EMPLOYEE__LOCALR__7F628407] DEFAULT (''),
[LOCALEXTRARIGHT] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__EMPLOYEE__LOCALE__0056A840] DEFAULT (''),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__EMPLOYEE__SRC__014ACC79] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__EMPLOYEE__LSTUPD__023EF0B2] DEFAULT (getdate()),
[ISUSETOKEN] [smallint] NOT NULL CONSTRAINT [DF__EMPLOYEE__ISUSET__4CECDE2A] DEFAULT (0),
[AccLock] [smallint] NULL,
[ISSPECLIM] [smallint] NOT NULL CONSTRAINT [DF__EMPLOYEE__ISSPEC__3E38A332] DEFAULT (0),
[SECURITYSTY] [int] NOT NULL CONSTRAINT [DF__EMPLOYEE__SECURI__5AF80ACD] DEFAULT (1),
[PDARIGHT] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__EMPLOYEE__PDARIG__240893ED] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EMP_DLT] on [dbo].[EMPLOYEE] for delete as
begin
  if exists (select * from deleted where GID = 1)
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
    return
  end
  delete from EMPLOYEERIGHT
    from DELETED
    where EMPLOYEERIGHT.EMPLOYEE = DELETED.GID
  delete from EMPXLATE from deleted where GID = LGID
  delete from WRHEMP from deleted where EMPGID = GID
  delete from BRANDEMP from deleted where EMPGID = GID
  delete from DEPTEMP from deleted where EMPGID = GID

end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EMP_INS] on [dbo].[EMPLOYEE] for insert as
begin
  declare
    @v_MaxNo Int,
    @GId int,
    @SecuritySty int,
    @v_OperName varchar(64),
    @Password char(32)

  --同步总表
  insert into EMPLOYEEH (GID, CODE, NAME, IDCARD, WORKTYPE, DISCOUNT, CREATEDATE,
	PASSWORD, LOCALRIGHT, LOCALEXTRARIGHT, MEMO, SRC, SNDTIME, LSTUPDTIME, ISUSETOKEN, ISSPECLIM,--zz 090104
	SECURITYSTY)
  select inserted.GID, inserted.CODE, inserted.NAME, inserted.IDCARD, inserted.WORKTYPE,
	inserted.DISCOUNT, inserted.CREATEDATE, inserted.PASSWORD, EMPLOYEE.LOCALRIGHT,
	inserted.LOCALEXTRARIGHT, inserted.MEMO, inserted.SRC, inserted.SNDTIME, inserted.LSTUPDTIME,inserted.ISUSETOKEN,
	inserted.ISSPECLIM,--zz 090104
	inserted.SECURITYSTY
  from INSERTED, EMPLOYEE
  where inserted.GID = EMPLOYEE.GID

  --同步网络本地对照表
  insert into EMPXLATE (NGID,LGID) select GID,GID from inserted

  --密码策略相关
  select @GId = GId, @SecuritySty = SecuritySty, @Password = Password
    from inserted

  --密码策略中的重复登录错误次数控制
  Update FAUserLogInLog Set ErrTimes = 0, LstUpdTime = GetDate() Where UserGid = @GId
  if @@RowCount = 0
    Insert Into FAUserLogInLog (UserGID, LstUpdTime, LastModifyOper, LstLoginTime, ErrTimes)
      Values(@GId, GetDate(), '未知[-]', Null, 0)

  --轨迹日志
  --更新上一条
  Select @v_MaxNo = ISNull(Max(No), 0) From FAUserStyLog Where UserGid = @GId;
  Update FAUserStyLog Set EDate = GetDate() - 1.0/60.0/60.0/24.0 Where UserGid = @GId and No = @v_MaxNo

  --新增下一条
  exec PFA_SYS_GETCUROPERNAMECODE @v_OperName output
  Insert Into FAUserStyLog(No, BDate, EDate, UserGID, StyGId, LstUpdTime, LastModifyOper)
    Values (@v_MaxNo + 1, GetDate(), Cast('2099.12.31' as DateTime), @GId, @SecuritySty, GetDate(), @v_OperName)

  --员工密码日志
  insert into FAUSERPWDLOG(USERGID, PASSWORD, LSTUPDTIME)
    values(@GId, @Password, getdate())
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EMP_UPD] on [dbo].[EMPLOYEE] for update as
begin
  declare
    @v_MaxNo Int,
    @GId int,
    @SecuritySty int,
    @v_OperName varchar(64),
    @Password char(32)

  --同步总表
  delete from EMPLOYEEH
    from DELETED
    where EMPLOYEEH.GID = DELETED.GID

  insert into EMPLOYEEH (GID, CODE, NAME, IDCARD, WORKTYPE, DISCOUNT, CREATEDATE,
	PASSWORD, LOCALRIGHT, LOCALEXTRARIGHT, MEMO, SRC, SNDTIME, LSTUPDTIME,ISUSETOKEN, ISSPECLIM,--zz 090104
	SECURITYSTY)
  select inserted.GID, inserted.CODE, inserted.NAME, inserted.IDCARD, inserted.WORKTYPE,
	inserted.DISCOUNT, inserted.CREATEDATE, inserted.PASSWORD, EMPLOYEE.LOCALRIGHT,
	inserted.LOCALEXTRARIGHT, inserted.MEMO, inserted.SRC, inserted.SNDTIME, inserted.LSTUPDTIME,inserted.ISUSETOKEN,
	inserted.ISSPECLIM,--zz 090104
	inserted.SECURITYSTY
  from INSERTED, EMPLOYEE
  where inserted.GID = EMPLOYEE.GID

  --密码策略相关
  select @GId = GId, @SecuritySty = SecuritySty, @Password = Password
    from inserted

  --密码策略中的重复登录错误次数控制
  if exists (select 1 from deleted t, inserted d where t.Acclock <> d.Acclock)
  begin
    Update FAUserLogInLog Set ErrTimes = 0, LstUpdTime = GetDate() Where UserGid = @GId;
    if @@RowCount = 0
      Insert Into FAUserLogInLog (UserGID, LstUpdTime, LastModifyOper, LstLoginTime, ErrTimes)
        Values(@GId, GetDate(), '未知[-]', Null, 0)
  end
  
  --轨迹日志
  if exists (select 1 from deleted t, inserted d where t.SecuritySty <> d.SecuritySty)
  begin
    --更新上一条
    Select @v_MaxNo = IsNull(Max(No), 0) From FAUserStyLog Where UserGid = @GId
    Update FAUserStyLog Set EDate = GetDate() - 1.0/60.0/60.0/24.0 Where UserGid = @GId and No = @v_MaxNo
    
    --新增下一条
    exec PFA_SYS_GETCUROPERNAMECODE @v_OperName output
    Insert Into FAUserStyLog(No, BDate, EDate, UserGID, StyGId, LstUpdTime, LastModifyOper) 
      Values (@v_MaxNo + 1, GetDate(), Cast('2099.12.31' as DateTime), @GId, @SecuritySty, GetDate(), @v_OperName)
  End

  --员工密码日志
  if update(PASSWORD)
  begin
    insert into FAUSERPWDLOG(USERGID, PASSWORD, LSTUPDTIME)
      values(@GId, @Password, getdate())
  end
end
GO
ALTER TABLE [dbo].[EMPLOYEE] ADD CONSTRAINT [PK__EMPLOYEE__63C3BFDC] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EMPLOYEE] ADD CONSTRAINT [UQ__EMPLOYEE__51BA1E3A] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
