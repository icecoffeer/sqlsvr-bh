CREATE TABLE [dbo].[FASECURITYSTY]
(
[GID] [int] NOT NULL,
[CODE] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ENGNAME] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SHORTCHNNAME] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SHORTENGNAME] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__FASECURIT__FILDA__5DD47778] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__FASECURIT__LSTUP__5EC89BB1] DEFAULT (getdate()),
[LASTMODIFYOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PWDMINLENGTH] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDMI__5FBCBFEA] DEFAULT (0),
[FIRSTLOGMSG] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__FIRST__60B0E423] DEFAULT (0),
[PWDERRTIMES] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDER__61A5085C] DEFAULT (3),
[PWDNEVERLOSE] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDNE__62992C95] DEFAULT (0),
[PWDEXPIRYDAY] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDEX__638D50CE] DEFAULT (0),
[PWDEXPIRYPROMPTDAY] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDEX__64817507] DEFAULT (0),
[PWDREUSELMT] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDRE__65759940] DEFAULT (0),
[PWDLEVEL] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDLE__6669BD79] DEFAULT (0),
[PWDSAMEPWDLNAME] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDSA__675DE1B2] DEFAULT (0),
[PWDDUPLIMIT] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDDU__685205EB] DEFAULT (0),
[PWDDEGREE] [smallint] NOT NULL CONSTRAINT [DF__FASECURIT__PWDDE__69462A24] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[FASECURITYSTY_DLT] on [dbo].[FASECURITYSTY] for DELETE
as
begin
  if exists (select * from deleted where GID = 1)
  begin
    rollback transaction
    raiserror('不能删除系统设定的记录', 16, 1)
  end
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[FASECURITYSTY_INS] on [dbo].[FASECURITYSTY] for INSERT
as
begin
  delete from FASECURITYSTYH
    from INSERTED
    where FASECURITYSTYH.GID = INSERTED.GID

  insert into FASECURITYSTYH
    select * from INSERTED

  declare @v_MaxNo Int, @Gid Int, @v_OperName varchar(64)

  --更新版本信息
  Select @Gid = Gid From INSERTED
  Select @v_MaxNo = IsNull(Max(No), 0) From FASecurityStyLog Where Gid = @Gid

  Update FASecurityStyLog Set EDate = GetDate() - 1/60/60/24 Where GId = @GId and No = @v_MaxNo

  exec PFA_SYS_GETCUROPERNAMECODE @v_OperName output
  INsert Into FASecurityStyLog(Gid, Code, Name, EngName, ShortChnName, ShortEngName, Src, Fildate, Filler, Lstupdtime, Lastmodifyoper,
    Note, PwdMinLength, FirstLogMsg, PwdErrTimes, PwdNeverLose, PwdExpiryDay, PwdExpiryPromptDay, PwdReuseLmt, PwdLevel,
    BDate, EDate, No, NoLstUpdTime, NoLastModifyOper,  PWDDUPLIMIT, PWDSAMEPWDLNAME, PWDDEGREE)
  Select Gid, Code, Name, EngName, ShortChnName, ShortEngName, Src, Fildate, Filler, Lstupdtime, Lastmodifyoper,
    Note, PwdMinLength, FirstLogMsg, PwdErrTimes, PwdNeverLose, PwdExpiryDay, PwdExpiryPromptDay, PwdReuseLmt, PwdLevel,
    GetDate(), cast('2099.12.31' as DateTime), @v_MaxNo + 1, getDate(), @v_OperName, PWDDUPLIMIT, PWDSAMEPWDLNAME, PWDDEGREE
      From INSERTED Where Gid = @GId
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[FASECURITYSTY_UPD] on [dbo].[FASECURITYSTY] for UPDATE
as
begin
  delete from FASECURITYSTYH
    from DELETED
    where FASECURITYSTYH.GID = DELETED.GID

  insert into FASECURITYSTYH
    select * from INSERTED

  declare @v_MaxNo Int, @Gid Int, @v_OperName varchar(64)

  --更新版本信息
  Select @Gid = Gid From INSERTED
  Select @v_MaxNo = IsNull(Max(No), 0) From FASecurityStyLog Where Gid = @Gid

  Update FASecurityStyLog Set EDate = GetDate() - 1/60/60/24 Where GId = @GId and No = @v_MaxNo;

  exec PFA_SYS_GETCUROPERNAMECODE @v_OperName output
  INsert Into FASecurityStyLog(Gid, Code, Name, EngName, ShortChnName, ShortEngName, Src, Fildate, Filler, Lstupdtime, Lastmodifyoper,
    Note, PwdMinLength, FirstLogMsg, PwdErrTimes, PwdNeverLose, PwdExpiryDay, PwdExpiryPromptDay, PwdReuseLmt, PwdLevel,
    BDate, EDate, No, NoLstUpdTime, NoLastModifyOper,  PWDDUPLIMIT, PWDSAMEPWDLNAME, PWDDEGREE)
  Select Gid, Code, Name, EngName, ShortChnName, ShortEngName, Src, Fildate, Filler, Lstupdtime, Lastmodifyoper,
    Note, PwdMinLength, FirstLogMsg, PwdErrTimes, PwdNeverLose, PwdExpiryDay, PwdExpiryPromptDay, PwdReuseLmt, PwdLevel,
    GetDate(), cast('2099.12.31' as DateTime), @v_MaxNo + 1, getDate(), @v_OperName,  PWDDUPLIMIT, PWDSAMEPWDLNAME, PWDDEGREE
      From INSERTED Where Gid = @GId
end

GO
ALTER TABLE [dbo].[FASECURITYSTY] ADD CONSTRAINT [PK__FASECURITYSTY__6A3A4E5D] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
