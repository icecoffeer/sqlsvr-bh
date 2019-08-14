SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[StkOutChk_Check](
  @cls char(10),
  @destgid int,
  @billtogid int,
  @num char(10),
  @msg varchar(100) output
)
With Encryption As
begin
  declare
    @isltd int,
    @destcode varchar(50),
    @destname varchar(100),
    @opt_UseLeagueStore int,
    @account1 money, @account2 money, @account3 money

  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output

  if @cls = '配货'
  begin
    select @destcode = CODE, @destname = NAME, @isltd = ISLTD
      from store (nolock) where gid = @destgid
    if @isltd = 1
    begin
      set @msg = rtrim(@destcode) + '[' + rtrim(@destname) + ']已经被限制配货'
      return(1)
    end
    if @billtogid <> @destgid
    begin
      select @destcode = CODE, @destname = NAME, @isltd = ISLTD
        from store (nolock) where gid = @billtogid
      if @isltd = 1
      begin
        set @msg = rtrim(@destcode) + '[' + rtrim(@destname) + ']已经被限制配货'
        return(2)
      end
    end
  end else if @cls = '批发'
  begin
    select @destcode = CODE, @destname = NAME, @isltd = ISLTD
      from client (nolock) where gid = @destgid
    if @isltd = 4
    begin
      set @msg = rtrim(@destcode) + '[' + rtrim(@destname) + ']已经被限制销售'
      return(3)
    end
    if @billtogid <> @destgid
    begin
      select @destcode = CODE, @destname = NAME, @isltd = ISLTD
        from client (nolock) where gid = @billtogid
      if @isltd = 4
      begin
        set @msg = rtrim(@destcode) + '[' + rtrim(@destname) + ']已经被限制销售'
        return(4)
      end
    end
  end

  declare @UseAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
  if @opt_UseLeagueStore = 1 and @cls = '配货'
  begin
    select @account1 = total from stkout(nolock) where cls = @cls and num = @num
    select @account2 = total, @account3 = account, @UseAccount = USEACCOUNT from LEAGUESTOREALCACCOUNT(nolock) --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    where storegid = @billtogid
    if (@account3 + @account2 - @account1 < 0) and (@UseAccount <> 0) --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    begin
      set @msg = '该门店配货信用额与交款额不足,不能配货'
      return(5)
    end
  end

  return(0)
end
GO
