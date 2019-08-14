SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashChgStat] (
  @num char(14),
  @tostat int,
  @oper  int
)
as
begin
  declare @fromstat int
  declare @return_status int
  declare @opername char(50)
  declare @vat Money
  declare @ShouldPay Money
  declare @Paid Money
  declare @TotalPay Money
	declare @UsePayReg int

  select @opername = rtrim(name) + '[' + rtrim(code) + ']'
  from employee(nolock) where gid = @oper

  select @fromstat = stat, @ShouldPay = SaleTotal - GapMoney from cntrpaycash where num = @num
  select @vat = Sum(Total) from CNTRPAYCASHVATDTL where NUM = @num
  if @fromstat is null
  begin
    raiserror('付款单%s不存在，可能已经被删除', 16, 1, @num)
    return 1
  end

  if @tostat = 100	/*审核*/
  begin
  	if @fromstat not in (0, 2100 , 2200, 2300)
  	begin
  	  raiserror('付款单%s不是未审核单据', 16, 1, @num)
  	  return 2
  	end

  	exec @return_status = CntrPayCashDoChk @num
  	if @return_status <> 0 return @return_status
    update cntrpaycash set stat = @tostat, checker = @opername, chkDate=GETDATE() where num = @num
    insert into cntrpaycashchklog(num, chkflag, oper, atime)
    values(@num, 100, @oper, getdate())
  end else if @tostat = 110	/*作废*/
  begin
  	if @fromstat not in (100,904)
  	begin
  	  raiserror('付款单%s不是已审核或者付款中的单据，不能作废', 16,1, @num)
  	  return 3
  	end
  	exec @return_status = CntrPayCashDoAbolish @num
  	if @return_status <> 0 return @return_status
    update cntrpaycash set stat = @tostat where num = @num
    insert into cntrpaycashchklog(num, chkflag, oper, atime)
    values(@num, 110, @oper, getdate())
  end else if @tostat = 900 /*付款*/
  begin
  	if @fromstat not in (100,904)
  	begin
  	  raiserror('付款单%s不是已审核或者付款中的单据，不能付款', 16, 1, @num)
  	  return 4
  	end
  	/*付款登记数额不符，则不能改成“已付款”状态*/
  	select @UsePayReg = optionvalue from hdoption where moduleno = 3108 and optioncaption = 'UsePayReg'
  	if @UsePayReg = 1
  	begin
  		select @Paid = sum(total) from cntrcheque where cls = '付款单' and num = @num
  		select @TotalPay = PayTotal from cntrpaycash where num = @num
  		if IsNull(@Paid,0) <> @TotalPay
  		begin
  			raiserror('付款单%s的实付金额与付款登记金额不符！', 16,1, @num)
  			return 7
  		end
		end 
  	exec @return_status = CntrPayCashDoPay @num, @oper
  	if @return_status <> 0 return @return_status
    update cntrpaycash set stat = @tostat, payer = @opername, paytime = getdate() where num = @num
    insert into cntrpaycashchklog(num, chkflag, oper, atime)
    values(@num, 900, @oper, getdate())
  end else if @tostat = 904 /*付款中*/
  begin
  	if @fromstat <> 100
  	begin
  	  raiserror('付款单%s不是已审核的单据，不能进行付款！', 16, 1, @num)
  	  return 6
  	end
  	update cntrpaycash set stat = @tostat where num = @num
    insert into cntrpaycashchklog(num, chkflag, oper, atime)
    values(@num, @tostat, @oper, getdate())
  end else if @tostat in (2100, 2200, 2300)
  begin
    if @fromstat >= @tostat
  	begin
  	  raiserror('付款单%s分级审核出错', 16,1, @num)
  	  return 5
  	end
  	update cntrpaycash set stat = @tostat where num = @num
    insert into cntrpaycashchklog(num, chkflag, oper, atime)
    values(@num, @tostat, @oper, getdate())
  end
  return 0
end
GO
