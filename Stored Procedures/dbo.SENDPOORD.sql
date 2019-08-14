SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SENDPOORD]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
) --WITH ENCRYPTION
AS
BEGIN
    DECLARE
      @SRC INT,   @ID  INT,
      @RCV INT,   @STAT SMALLINT

    SELECT @STAT = STAT
    FROM PURCHASEORDER(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS

    --CHECK
    IF @STAT not in (3200, 300, 100, 110, 1000)
    BEGIN
      SET @MSG = '[发送]单据' + @NUM + ':是未审核状态，不允许发送'
      RETURN 1
    END

    IF @STAT in (3200, 300, 100, 110, 1000)
    BEGIN
      IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID = ZBGID)
      BEGIN
        SET @MSG = '[发送]单据' + @NUM + ':总部不能发送销售定货单'
        RETURN 2
      END
    END

    --BEGIN TO SEND
    SELECT @SRC = USERGID FROM SYSTEM(NOLOCK)
    SELECT @RCV = ZBGID FROM SYSTEM(NOLOCK)

    UPDATE PURCHASEORDER SET SNDTIME = GETDATE() WHERE NUM = @NUM AND CLS = @CLS

    EXECUTE GETNETBILLID @ID OUTPUT

    INSERT INTO NPURCHASEORDER(NUM, CLS, SETTLENO, VENDOR, TOTAL, TAX, RTLTOTAL, ORDAMT, NOTE, FILDATE,
      FILLER, CHECKER, STAT, WRH, RECCNT, SRC, SRCNUM, SNDTIME, RECEIVER, PSR, PRNTIME,
      PRECHECKER, PRECHKDATE, DEPT, CUSTOMIZETYPE, RCVTYPE, SELLERAPPROVEOPERATOR,
      SELLERREFNUMBER, SELLERAPPROVETIME, SUPPLIERORDERTIME, SELLERREMARK, BUYERNAME, BUYERREFNUMBER, BUYERADDRESS,
      BUYERTELEPHONE, BUYERORDERTIME, BUYERORDEREXPIRATIONDATE, BUYERORDERTYPE, BUYERFILDATE,
      BUYERSELLOPERATOR, BUYERCUSTMIZEDIMAGE, BUYERINVOICENUMBER, SUPPLIERCODE, SUPPLIERNAME,
      CONFIRMDATE, CONFIRMER, CHKDATE, LSTUPDTIME, ID, NSTAT, RCV, RCVTIME, TYPE, NNOTE, SellerConInfo, FINISHEDDATE)
    SELECT NUM, CLS, SETTLENO, VENDOR, TOTAL, TAX, RTLTOTAL, ORDAMT, NOTE, FILDATE,
      FILLER, CHECKER, STAT, WRH, RECCNT, @SRC, SRCNUM, SNDTIME, RECEIVER, PSR, PRNTIME,
      PRECHECKER, PRECHKDATE, DEPT, CUSTOMIZETYPE, RCVTYPE, SELLERAPPROVEOPERATOR,
      SELLERREFNUMBER, SELLERAPPROVETIME, SUPPLIERORDERTIME, SELLERREMARK, BUYERNAME, BUYERREFNUMBER, BUYERADDRESS,
      BUYERTELEPHONE, BUYERORDERTIME, BUYERORDEREXPIRATIONDATE, BUYERORDERTYPE, BUYERFILDATE,
      BUYERSELLOPERATOR, BUYERCUSTMIZEDIMAGE, BUYERINVOICENUMBER, SUPPLIERCODE, SUPPLIERNAME,
      CONFIRMDATE, CONFIRMER, CHECKDATE, LSTUPDTIME, @ID, 0, @RCV, NULL, 0, NULL, SellerConInfo, FINISHEDDATE
    FROM PURCHASEORDER(NOLOCK)
    WHERE NUM = @NUM AND CLS = @CLS

    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送' + @NUM + '单据失败'
        RETURN 3
    END

    INSERT INTO NPURCHASEORDERDTL (NUM, CLS, LINE, GDGID, ORDQTY, PRICE, TOTAL, TAX, ORDPRC, ORDAMT, WRH,
      INVQTY, ARVQTY, BCKQTY, NOTE, FLOWNO, POSNO, RTLQTY, RTLBCKQTY, RTLPRC, RTLTOTAL,
      PRNUM, SRC, ID)
    SELECT NUM, CLS, LINE, GDGID, ORDQTY, PRICE, TOTAL, TAX, ORDPRC, ORDAMT, WRH,
      INVQTY, ARVQTY, BCKQTY, NOTE, FLOWNO, POSNO, RTLQTY, RTLBCKQTY, RTLPRC, RTLTOTAL,
      PRNUM, @SRC, @ID
    FROM PURCHASEORDERDTL(NOLOCK)
    WHERE NUM = @NUM AND CLS = @CLS

    declare
      @posno char(10), @flowno char(12), @realamt money, @reccnt int, @guest int, @cardcode char(20), @client varchar(100),
      @qty money, @nCrmRunMode int

    if exists(select 1 from HDOPTION(NOLOCK) where MODULENO = 0 and OPTIONCAPTION = 'MemRunMode'
      and OPTIONVALUE = 'HDCRM')
      select @nCrmRunMode = 1
    else
      select @nCrmRunMode = 0

    declare cur_nTransDtl cursor for
      select distinct POSNO, FLOWNO from PURCHASEORDERDTL where NUM = @num and CLS = @cls
    open cur_nTransDtl
	fetch next from cur_nTransDtl into
		@posno, @flowno
	while @@fetch_status = 0
	begin
	  select @realamt = REALAMT, @reccnt = RECCNT, @guest = GUEST, @cardcode = CARDCODE from BUY1(NOLOCK) where POSNO = @posno and FLOWNO = @flowno
	  select @qty = sum(qty) from BUY2(NOLOCK) where POSNO = @posno and FLOWNO = @flowno
	  if @nCrmRunMode = 0
	  begin
	    if @guest <> -1
	      select @client = '[' + CARD.CODE + ']' + '[' + CLIENT.NAME + ']' from CLIENT(NOLOCK), CARD(NOLOCK)
	        where CLIENT.GID = CARD.CSTGID and CARD.GID = @guest
	  end
	  else
	  begin
	    if @cardcode <> ''
	      select @client = '[' + C.CARDNUM + ']' + '[' + m.NAME + ']' from CRMCARD C(NOLOCK), CRMMEMBER m(NOLOCK)
	        where c.CARRIER = m.GID and c.CARDNUM = @cardCode
	  end
	  INSERT INTO NPURCHASEORDERTRANSDTL(NUM, CLS, POSNO, FLOWNO, REALAMT, RECCNT, QTY, GUEST, SRC, ID)
	    VALUES(@NUM, @CLS, @posno, @flowno, @realamt, @reccnt, @qty, @client, @src, @id)
	  fetch next from cur_nTransDtl into
	    @posno, @flowno
	end
	close cur_nTransDtl
	deallocate cur_nTransDtl

    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送' + @NUM+ '单据失败'
        RETURN 4
    END

    EXEC PURCHASEORDADDLOG @NUM, @CLS, @STAT, '发送', @OPER

    SET @MSG = '发送' + @NUM + '单据成功'

    RETURN 0
END
GO
