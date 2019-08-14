SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashChkStep] (
  @num	char(14),
  @action	varchar(10),
  @oper	int
)
as
begin
  declare @chkflag int, @stat int, @chkint int
  select @chkflag = chkflag, @stat = stat from cntrpaycash where num = @num
  if @@rowcount = 0
    raiserror('付款单%s不存在', 16, 1, @num)
  else if @stat <> 0
    raiserror('付款单%s不是未审核单据', 16, 1, @num)
  else if (@action = '一审') and (@chkflag >= 1)
      raiserror('付款单%s无法一审', 16, 1, @num)
  else if (@action = '二审') and (@chkflag >= 2)
      raiserror('付款单%s无法二审', 16, 1, @num)
  else if (@action = '三审') and (@chkflag >= 4)
      raiserror('付款单%s无法三审', 16, 1, @num)
  else if (@action = '四审') and (@chkflag >= 8)
      raiserror('付款单%s无法四审', 16, 1, @num)
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
  	update cntrpaycash set chkflag = @chkflag where num = @num
      insert into cntrpaycashchklog(num, chkflag, oper, atime)
      values(@num, @chkint, @oper, getdate())
  end
end
GO
