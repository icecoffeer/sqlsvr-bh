SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PURCHASEORDER_CHECK_1600TO100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
with Encryption
as
begin
  DECLARE
    @EMPGID INT,
    @SRCNUM CHAR(14),
    @GDGID INT,
    @ARVQTY MONEY,
    @poNum char(14),
    @stat smallint,
    @cur_date datetime,
    @cur_settleno int,
    @fildate datetime,
    @settleno int,
    @wrh int,
    @billto int,
    @psr int,
    @qty money,
    @price money,
    @total money,
    @tax money,
    @loss money,
    @inprc money,
    @rtlprc money,
    @acnt smallint,
    @return_status int,
    @dtlline int,
    @opt_GenDlv int,
    @BUYERREFNUMBER varCHAR(255),
    @xflowno varchar(20),
    @xposno varchar(10)


  select @poNum = SRCNUM, @BUYERREFNUMBER = BUYERREFNUMBER from PURCHASEORDER(NOLOCK) where NUM = @NUM and CLS = @CLS

  select @stat = STAT from PURCHASEORDER(NOLOCK) where NUM = @poNum and CLS = '销售定货'
  if @stat <> 3200
  begin
     select @Msg = '当前销售定货进货单的来源销售定货单[' + @poNum + ']的状态不是已确认,不允许审核 '
     return(1)
  end

  SELECT @EMPGID = GID FROM EMPLOYEE(NOLOCK) WHERE
    CODE = SUBSTRING(@OPER, CHARINDEX('[',@OPER) + 1, LEN(@OPER) - CHARINDEX('[',@OPER) - 1)
    AND NAME = SUBSTRING(@OPER, 1, CHARINDEX('[',@OPER) - 1)

  SELECT @SRCNUM = SRCNUM FROM PURCHASEORDER(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS

  select @cur_settleno = MAX(NO) from MONTHSETTLE
  select
    @cur_date = convert(datetime, convert(char, getdate(), 102)),
    @settleno = SETTLENO,
    @fildate = FILDATE,
    @wrh = WRH,
    @billto = VENDOR,
    @psr = PSR,
    @acnt = 0,
    @loss = 0
  from PURCHASEORDER where CLS = @cls and NUM = @num


  declare c_cursor cursor for
    select p.GDGID, p.ARVQTY, p.PRICE, p.TOTAL, p.TAX, g.inprc, g.rtlprc, P.WRH, line, posno, flowno
    from PURCHASEORDERDTL p(nolock), goodsh g(nolock)
    where p.CLS = @CLS and p.NUM = @NUM and p.gdgid = g.gid
  open c_cursor
  fetch next from c_cursor into
    @gdgid, @qty, @price, @total, @tax, @inprc, @rtlprc, @WRH, @dtlline, @xposno, @xflowno
  while @@fetch_status = 0
  begin
    declare
      @ordbckqty money, @ordqty money
	  if not exists (select 1 from goods(nolock) where gid = @gdgid) and @qty > 0
      begin
			declare @code char(13)
			select @code = (select code from goodsh(nolock) where gid = @gdgid)
	  	select @msg = '已经删除的商品[' + @code + ']收货数量不能大于0'
	  	set @return_status = 1
	  	break
	  end

    select @ordqty = ORDQTY from PURCHASEORDERDTL(NOLOCK) where NUM = @srcnum and CLS = '销售定货'
      and GDGID = @GDGID and posno = @xposno and flowno = @xflowno
    select @ordbckqty = isnull(sum(BCKQTY), 0) from PURCHASEORDERDTL(NOLOCK)
    where num in (select NUM from PURCHASEORDER(NOLOCK) where CLS = '销售退货' and SRCNUM = @SRCNUM
      and STAT = 3200) and CLS = '销售退货' and GDGID = @gdgid and posno = @xposno and flowno = @xflowno

    if @qty <> (@ordQty - @ordbckqty)
    begin
      select @Msg = '单据第' + convert(varchar(3), @dtlline) + '行的收货数' + convert(varchar, @qty) + '不等于定货数与退货数的差额'
          + convert(varchar(10), @ordQty - @ordbckQty) + '，不允许审核!'
      select @return_status = 1
      break;
    end

    update PURCHASEORDERDTL set ARVQTY = @QTY + ARVQTY
    where num = @SRCNUM and cls = '销售定货' AND GDGID = @GDGID and POSNO = @XPOSNO AND FLOWNO = @XFLOWNO

    execute UPDINVPRC '进货', @gdgid, @qty, @total, @wrh

    execute @return_status = LOADIN @wrh, @gdgid, @qty, @rtlprc, null
    if @return_status <> 0 break

    execute @return_status = PURCHASEORDERDTLCRT
      @cur_date, @cur_settleno, @fildate, @settleno,
      @cls, @wrh, @gdgid, @billto, @psr, @qty, @price,
      @total, @tax, @loss, @inprc, @rtlprc, @acnt

    if @return_status <> 0 break

    fetch next from c_cursor into
      @gdgid, @qty, @price, @total, @tax, @inprc, @rtlprc, @WRH, @dtlline, @xposno, @xflowno

  end
  close c_cursor
  deallocate c_cursor

  if @return_status <> 0 return @return_status

  update PURCHASEORDER SET STAT = 1000, LSTUPDTIME = getdate(), FINISHEDDATE = getdate()
  WHERE NUM = @SRCNUM AND CLS = '销售定货'

  EXEC PURCHASEORDADDLOG @SRCNUM, '销售定货', 1000, '已收货', @OPER

  --IF (SELECT OPTIONVALUE FROM HDOPTION WHERE OPTIONCAPTION = 'AutoSndOnChk' AND MODULENO = 665) = 1
  --begin
    declare @ORDNUM char(14)
    SELECT @ORDNUM = SRCNUM FROM PURCHASEORDER(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS
    EXEC SENDPOORD @ORDNUM, @OPER, '销售定货', 0, ''
  --end

  update PURCHASEORDER set CHECKER = @OPER, CHECKDATE = getdate(), Stat = @ToStat, LSTUPDTIME = getdate()
  where num = @NUM and cls = @CLS

  if exists(select 1 from HDOPTION(NOLOCK) where MODULENO = 665 and OPTIONCAPTION = 'AutoGenDlv'
    and OPTIONVALUE = '1')
    select @opt_GenDlv = 1
  else
    select @opt_GenDlv = 0
  if @opt_GenDlv = 1 and ((select RCVTYPE from PURCHASEORDER(nolock) where NUM = @NUM AND CLS = @CLS) = '本店送货至顾客处')
  begin
    DECLARE @NUMMID VARCHAR(10), @GNUM VARCHAR(10),
      @BUYERADDRESS varchar(255), @BuyerTelephone varchar(255),
      @BuyerOrderTime datetime, @BUYERNAME varchar(255), @client int,
      @line int, @POSNO char(12), @itemno int, @FLOWNO char(12),
      @PROVINCE varchar(255), @COUNTY varchar(255), @MANSION varchar(255),
      @ADDRCODE varchar(255), @ROAD varchar(255), @NEARBY varchar(64), @Lane varchar(10),
      @Building varchar(10), @room varchar(10), @BUYERREGIONDTL varchar(38),
      @aa varchar(30), @note varchar(255), @DLVNUM VARCHAR(10)

    SELECT @DLVNUM = MAX(NUM) FROM DLV(NOLOCK)
    EXEC NEXTBN @DLVNUM, @GNUM OUTPUT

    IF @GNUM IS NULL SET @GNUM = '0000000001'
    set @aa = '生成送货单' + RTRIM(@GNUM)

    SELECT @SETTLENO =  MAX(NO) FROM MONTHSETTLE(NOLOCK)

    select @BUYERADDRESS = BUYERADDRESS, @BuyerTelephone = BuyerTelephone, @BUYERNAME = BUYERNAME
    from PURCHASEORDER(nolock)
    where CLS = @CLS and NUM = @NUM

    select @NEARBY = NEARBY, @BuyerOrderTime = BuyerOrderTime, @LANE = LANE, @BUILDING = BUILDING, @ROOM = ROOM, @note = NOTE
      from PURCHASEORDER(NOLOCK) where NUM = @SRCNUM and CLS = '销售定货'

    select @client = gid from client(nolock) where name like '%' + @BUYERNAME
    if @client is null set @client = 1

    select @PROVINCE = a.PROVINCE, @COUNTY = a.COUNTY, @MANSION = a.MANSION, @ADDRCODE = a.CODE, @ROAD = a.ROAD, @BUYERREGIONDTL = a.uuid
    from addrinfodtl a(nolock), PURCHASEORDER p(nolock) where a.UUID = p.BUYERREGIONDTL and p.NUM = @SRCNUM AND p.CLS = '销售定货'

    insert into DLV(NUM, SETTLENO, FILDATE, FILLER, CLIENT, CTRNAME, ADDR,
      CTRTEL, BKDATE, DELIVERYMAN, STAT, NOTE, LSTUPDTIME, CLS, PROVINCE, COUNTY, MANSION, ADDRCODE, ROAD,
      NEARBY, SUBROAD, BUILDING, ROOM, ADDRUUID, FROMCLS, FROMNUM)
    values(@GNUM, @SETTLENO, getdate(), @EMPGID, @client, @BUYERNAME, @BUYERADDRESS,
      @BuyerTelephone, @BuyerOrderTime, 1, 0, '手工销售单号:' + rtrim(@BUYERREFNUMBER) + ', 电脑定单号：' + substring(rtrim(@SRCNUM), 5, 10)
      + ' 由销售定货进货单' + @NUM + '生成。', getdate(), '零售', @PROVINCE,
      @COUNTY, @MANSION, @ADDRCODE, @ROAD, @NEARBY, @LANE, @BUILDING, @ROOM, @BUYERREGIONDTL, '销售定货进货', @NUM)

    set @line = 1
    declare c_cursor cursor for
      select GDGID, ARVQTY, POSNO, FLOWNO, NOTE
      from PURCHASEORDERDTL p(nolock)
      where p.CLS = @CLS and p.NUM = @NUM
    open c_cursor
    fetch next from c_cursor into @GDGID, @ARVQTY, @POSNO, @FLOWNO, @NOTE
    while @@fetch_status = 0
    begin
      select @itemno = itemno from buy2(nolock) where POSNO = @POSNO and FLOWNO = @FLOWNO
        and GID = @gdgid
      if @itemno is null set @itemno = 1
      insert into DLVDtl(NUM, CLS, LINE, GDGID, QTY, POSNO, FLOWNO, QPCGID, QPCQTY, ITEMNO, NOTE)
      values(@GNUM, '零售', @line, @GDGID, @ARVQTY, @POSNO, @FLOWNO, @GDGID, @ARVQTY, @itemno, rtrim(@NOTE) + ' 手工销售单号:' + rtrim(@BUYERREFNUMBER) + ', 电脑定单号：' + substring(rtrim(@SRCNUM), 5, 10))
      set @line = @line + 1
      fetch next from c_cursor into @GDGID, @ARVQTY, @POSNO, @FLOWNO, @NOTE
    end
    close c_cursor
    deallocate c_cursor

    UPDATE PURCHASEORDER SET NOTE = RTRIM(@aa) + RTRIM(NOTE) where num = @NUM and cls = @CLS

    EXEC PURCHASEORDERADDLOG @NUM, @CLS, 100, @aa, @OPER
  end
  UPDATE PURCHASEORDER SET BuyerOrderTime = convert(datetime, convert(char, getdate(), 102)) where num = @NUM and cls = @CLS
  EXEC PURCHASEORDERADDLOG @NUM, @CLS, 100, '审核', @OPER

  IF (SELECT OPTIONVALUE FROM HDOPTION WHERE OPTIONCAPTION = 'AutoSndOnChk' AND MODULENO = 665) = 1
    EXEC PURCHASESTKIN_SND @NUM, @OPER, @CLS, 100, '', 0  --最后个参数0表示不附带发送其他单据

  --if not (@opt_GenDlv = 1 and ((select RCVTYPE from PURCHASEORDER(nolock) where NUM = @NUM AND CLS = @CLS) = '本店送货至顾客处'))
  if (select RCVTYPE from PURCHASEORDER(nolock) where NUM = @NUM AND CLS = @CLS) = '供应商送货至顾客处'
    or (select RCVTYPE from PURCHASEORDER(nolock) where NUM = @NUM AND CLS = @CLS) = '顾客至供货方处自提'
  begin
    EXEC PURCHASEORDER_CHECK_100TO3200 @NUM, @OPER, @CLS, 3200, @MSG
  end

  return(0)
end
GO
