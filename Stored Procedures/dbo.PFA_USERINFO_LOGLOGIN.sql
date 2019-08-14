SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_USERINFO_LOGLOGIN](  
    @piUserCode varchar(30),  
  @piLoginFlag int,
  @piWorkStationNo varchar(10)
) as  
begin  
  declare
    @v_EmpGid int,
    @v_EmpName char(20),
    @v_LstModifyOper char(30),
    @v_CurErrTimes int,
    @v_StyErrTimes int,
    @v_Reccnt int
  
  Select @v_EmpGid = GId,@v_EmpName = NAME,
    @v_LstModifyOper = RTrim(Name) + '[' + RTrim(Code) + ']'
    From Employee(nolock) Where Code = @piUserCode
  
    If @@rowcount = 0  
  begin
    INSERT INTO [LOG] (TIME, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, CONTENT)
    VALUES(GETDATE(), @piUserCode, @v_EmpName, @piWorkStationNo, '系统登录失败，用户不存在！')
      return 0  
  end
  else if @piLoginFlag = 0
    INSERT INTO [LOG] (TIME, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, CONTENT)
    VALUES(GETDATE(), @piUserCode, @v_EmpName, @piWorkStationNo, '系统登录失败，密码错误！')
  
  Select @v_Reccnt = Count(1) From FAUserLoginLog(nolock) where UserGId = @v_EmpGid
  
    --登陆后记录登记日志0 失败 1 成功  
  
    begin transaction PFA_USERINFO_LOGLOGIN_TRAN  
  
    If @piLoginFlag = 1  
    begin  
      If @v_Reccnt <> 0  
      Update FAUserLoginLog Set ErrTimes = 0, LstLoginTime = GetDate() Where UserGId = @v_EmpGid
      else  
        Insert into FAUserLoginLog (UserGid, LstUpdTime, LastModifyOper, LstLoginTime, ErrTimes)  
        Values(@v_EmpGid, GetDate(), @v_LstModifyOper, GetDate(), 0)
    end  
    Else  
    begin  
      If @v_Reccnt <> 0  
      Update FAUserLoginLog Set ErrTimes = ErrTimes + 1 Where UserGId = @v_EmpGid
      Else  
        Insert into FAUserLoginLog (UserGid, LstUpdTime, LastModifyOper, LstLoginTime, ErrTimes)  
        Values(@v_EmpGid, GetDate(), @v_LstModifyOper, Null, 1)
  
    Select @v_CurErrTimes = ErrTimes From FAUserLoginLog(nolock) where UserGId = @v_EmpGid
    Select @v_StyErrTimes = PWDErrTimes From FASecuritySty fs(nolock), Employee fu(nolock)
    Where fs.GId = fu.SecuritySty and fu.GId = @v_EmpGid
  
      If @v_CurErrTimes >= @v_StyErrTimes  
      begin  
       --密码错误次数超过允许范围 锁定用户  
      Update Employee Set AccLock = 1 where Gid = @v_EmpGid
      end  
    end  
  
    commit transaction PFA_USERINFO_LOGLOGIN_TRAN  
  
    return 0  
end  
GO
