SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE procedure [dbo].[CntrPrePayChkStep] (
  @num	 char(14),
  @action	varchar(10),
  @oper	int
)
as
begin
  declare @chkflag int, @stat int, @chkint int
  select @chkflag = chkflag, @stat = stat from cntrPrepay where num = @num
  if @@rowcount = 0
    raiserror('预付款单%s不存在', 16, 1, @num)
  else if @stat <> 0
    raiserror('预付款单%s不是未审核单据', 16, 1, @num)
  else if (@action = '一审') and (@chkflag >= 1)
      raiserror('预付款单%s无法一审', 16, 1, @num)
  else if (@action = '二审') and (@chkflag >= 2)
      raiserror('预付款单%s无法二审', 16, 1, @num)
  else if (@action = '三审') and (@chkflag >= 4)
      raiserror('预付款单%s无法三审', 16, 1, @num)
  else if (@action = '四审') and (@chkflag >= 8)
      raiserror('预付款单%s无法四审', 16, 1, @num)
  else begin
  	if @action = '一审'
  	begin
  	  set @chkflag = @chkflag | 1
  	  set @chkint = 1
  	end else if @action = '二审'
  	begin
  	  set @chkflag = @chkflag | 2
  	  set @chkint = 2
  	end else if @action = '三审'
  	begin
  	  set @chkflag = @chkflag | 4
  	  set @chkint = 4
  	end else if @action = '四审'
  	begin
  	  set @chkflag = @chkflag | 8
  	  set @chkint = 8
  	end
  	update cntrPrepay set chkflag = @chkflag where num = @num
      insert into cntrPrepaychklog(num, chkflag, oper, atime)
      values(@num, @chkint, @oper, getdate())
  end
  Return 0
end
GO
