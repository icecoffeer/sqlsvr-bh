SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[INVOICECHK]
(
  @NUM VARCHAR(50),
  @TOSTAT INT,
  @OPER VARCHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
  declare
    @stat int,
    @ret smallint

  set @ret = 0
  select @stat = stat
  from INVOICE where num =@Num

  update INVOICE
  set stat = @TOSTAT, LstUpdTime = Getdate()
  where num = @num

  if @TOSTAT = 1600
    begin
    	update INVOICE
    	set prechecker = @OPER, prechkdate = Getdate()
    	where num = @num

    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '预审', @OPER, getdate())
    end
  else if @TOSTAT = 100
    begin
    	update INVOICE
    	set checker = @OPER, chkdate = getdate()
    	where num = @num

    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '审核', @OPER, getdate())
    end
  else if @TOSTAT = 110
    begin
    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '审核后作废', @OPER, getdate())
    end
  else if @TOSTAT = 134
    begin
    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '审核后修正', @OPER, getdate())
    end
  else if @TOSTAT = 600
    begin
    	insert into SHOULDPAYRPT(VDRGID, SETTLENO, CLS, NUM, LINE, SHOULDPAYCLS, SHOULDPAYNUM, TOTAL, PYTOTAL, PAYTAG)
    	select M.BILLTO, M.SETTLENO, 0, M.NUM, D.LINE, D.SHOULDPAYCLS, D.SHOULDPAYNUM, D.SHOULDPAYINVTOTAL, 0, 0
    	from INVOICE M(nolock), INVOICEDTL D(nolock)
    	where M.NUM = @NUM
    	  and M.NUM = D.NUM

    	update INVOICE
    	set verifier = @OPER, verifydate = Getdate()
    	where num = @num;

    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '复核', @OPER, getdate());
    end
  else if @TOSTAT = 610
    begin
    	delete from SHOULDPAYRPT
    	where CLS = 0
    	  and NUM = @NUM
    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '复核后作废', @OPER, getdate());
    end
  else if @TOSTAT = 634
    begin
    	delete from SHOULDPAYRPT
    	where CLS = 0
    	  and NUM = @NUM
     	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '复核后修正', @OPER, getdate());
    end
  else if @TOSTAT = 900
    begin
      update SHOULDPAYRPT
      set PAYTAG = 1
      where CLS = 0
    	  and NUM = @NUM

    	update INVOICE
    	set payer = @OPER, paydate = Getdate()
    	where num = @num;

    	insert into InvoiceLog(num, stat, act, modifier, time)
    	values(@num, @stat, '付款', @OPER, getdate());
    end

  if @ret = 1 set @msg = @msg + ',审核单据出错';
  return @ret;
End
GO
