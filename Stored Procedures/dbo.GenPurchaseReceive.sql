SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GenPurchaseReceive] (
  @Num char(14),
  @Cls char(10),
  @OPER varchar(30),
  @PRNum char(14) output,
  @Msg varchar(255) output
) as
begin
  declare
    @stat int,
    @rcvtype char(20),
    @src int,
    @usergid int,
    @newNum char(14),
    @INPRCAMT MONEY

  if not exists(select * from PURCHASEORDER where NUM = @num and CLS = @cls)
  begin
	select @Msg = '不存在要生成进货单的销售定货单'
  	return(1)
  end

  select @RCVTYPE = RCVTYPE, @stat = STAT from PURCHASEORDER where NUM = @num and CLS = @cls
  if @stat <> 3200
  begin
     select @MSg = '不允许未确认的销售定货单生成进货单'
     return(1)
  end

  if (@rcvtype <> '供应商送货至顾客处') and (@rcvtype <> '顾客至供货方处自提')
  begin
    select @Msg = '交货方式不是厂送的销售定货单不允许直接生成进货单'
    return(1)
  end

  select @usergid = usergid from system(nolock)
  if (@src <> @usergid)
  begin
     select @Msg = '来源单位不是本店的不允许生成进货单'
     return(1)
  end

  exec GENNEXTBILLNUM '销售进货', 'PURCHASEORDER', @newNum output

  DECLARE @FILLERCODE VARCHAR(20), @FILLER INT, @FILLERNAME VARCHAR(50)
  SET @FILLERCODE = RTRIM(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
  SELECT @FILLER = GID, @FILLERNAME = NAME FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE

  INSERT INTO PURCHASEORDER(NUM, CLS, SETTLENO, VENDOR, TOTAL, TAX, NOTE, FILDATE, FILLER,
    WRH, RECCNT, SRC, SRCNUM, RECEIVER, PSR, DEPT, CUSTOMIZETYPE, RCVTYPE, SELLERAPPROVEOPERATOR,
    SELLERREFNUMBER, SELLERAPPROVETIME, SUPPLIERORDERTIME, SELLERREMARK, BUYERNAME, BUYERREFNUMBER, BUYERADDRESS, BUYERTELEPHONE,
    BUYERORDERTIME, BUYERORDEREXPIRATIONDATE, BUYERORDERTYPE, BUYERFILDATE, BUYERSELLOPERATOR,
    BUYERCUSTMIZEDIMAGE, BUYERINVOICENUMBER, SUPPLIERCODE, SUPPLIERNAME)
  SELECT @newNum, '销售进货', SETTLENO, VENDOR, TOTAL, TAX, NOTE, getdate(), @FILLER,
    WRH, RECCNT, SRC, @NUM, RECEIVER, PSR, DEPT, CUSTOMIZETYPE, RCVTYPE, SELLERAPPROVEOPERATOR,
    SELLERREFNUMBER, SELLERAPPROVETIME, SUPPLIERORDERTIME, SELLERREMARK, BUYERNAME, BUYERREFNUMBER, BUYERADDRESS, BUYERTELEPHONE,
    BUYERORDERTIME, BUYERORDEREXPIRATIONDATE, BUYERORDERTYPE, BUYERFILDATE, BUYERSELLOPERATOR,
    BUYERCUSTMIZEDIMAGE, BUYERINVOICENUMBER, SUPPLIERCODE, SUPPLIERNAME
  FROM PURCHASEORDER(NOLOCK)
  WHERE num = @Num and CLS = @Cls

  INSERT INTO PURCHASEORDERDTL(NUM,CLS, LINE, GDGID, ORDQTY, PRICE, TOTAL, TAX, WRH, INVQTY,
    ARVQTY, BCKQTY, NOTE, FLOWNO, POSNO, RTLQTY, RTLBCKQTY, RTLPRC, RTLTOTAL,
    PRNUM, ORDPRC, ORDAMT, INPRC, INPRCAMT)
  SELECT @newNUM,'销售进货', D.LINE, D.GDGID, D.ORDQTY, D.PRICE, D.TOTAL, D.TAX, D.WRH, D.INVQTY,
    D.ORDQTY, D.BCKQTY, D.NOTE, D.FLOWNO, D.POSNO, D.RTLQTY, D.RTLBCKQTY, D.RTLPRC, D.RTLTOTAL,
    D.PRNUM, G.RTLPRC, D.ORDQTY * G.RTLPRC, G.INPRC, D.ORDQTY * G.INPRC
  FROM PURCHASEORDERDTL D(NOLOCK), GOODS G(NOLOCK)
  WHERE D.NUM = @NUM and D.CLS = @cls AND D.GDGID = G.GID

  SELECT @INPRCAMT = SUM(INPRCAMT) FROM PURCHASEORDERDTL WHERE CLS = '销售进货' AND NUM = @NEWNUM
  UPDATE PURCHASEORDER SET INPRCAMT = @INPRCAMT WHERE CLS = '销售进货' AND NUM = @NEWNUM

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '生成销售定货进货单' + @newNUM + '单据失败'
    RETURN 6
  END

  --RECEIVE BILL OVER
  set @Msg = '生成销售定货进货单: '+ @newNum
  EXEC PURCHASEORDADDLOG @NUM, @CLS, @STAT, @Msg, @OPER

  SET @MSG = '单据：' + @NUM + '生成销售定货进货单成功' + @MSG
  set @PRNum = @newNum

  RETURN 0
end
GO
