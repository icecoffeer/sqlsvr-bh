SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CopyToBuyFromSR](
  @num char(14),
  @cls char(10),
  @Msg varchar(200) output
) with encryption as
begin
  --复制buy1
  declare
    @posno char(10),
    @oldflowno char(12),
    @fillercode varchar(50),
    @cashier INT,
    @settleno int,
    @dealer int,
    @importtopo int,
    @datephase char(8),
    @getdatephase char(8),
    @flowno char(12),
    @curflowno varchar(12),
    @v_ret int
  select @importtopo = IMPORTTOPO, @dealer = DEALER, @posno = POSNO, @SETTLENO = SETTLENO, @fillercode = FILLER from STORERETAIL where NUM = @num AND CLS = @cls
  select @getdatephase = convert(char(8), getdate(), 112)
  select @curflowno = @getdatephase + '%'
  select @oldflowno = isnull(max(flowno), '') from BUY1(NOLOCK) where POSNO = @posno and FLOWNO like @curflowno
  select @datephase = substring(@oldflowno, 1, 8)
  if @datephase < @getdatephase
    select @flowno = @getdatephase + '0001'
  else
  begin
    EXEC @V_RET = NEXTFLOWNO @oldflowno, @flowno OUTPUT
    if @v_ret <> 0 return(1)
  end
  Select @FILLERCODE = RTRIM(SUBSTRING(@fillercode, CHARINDEX('[', @fillercode) + 1, len(@fillercode) - CHARINDEX('[', @fillercode) - 1))
  SELECT @CASHIER = GID FROM EMPLOYEE(NOLOCK) WHERE CODE = @FILLERCODE
  insert into BUY1 (FLOWNO, POSNO, SETTLENO, FILDATE, CASHIER, WRH, ASSISTANT, TOTAL, REALAMT, PREVAMT, RECCNT, MEMO, SCORE, CARDCODE, DEALER, FLAG, GUEST)
    select @FLOWNO, POSNO, SETTLENO, SellerApproveTime, @cashier, SellerWrh, @cashier, TOTAL, TOTAL, ReceiveTotal, Reccnt, Remark, Score, CARDNUM, @dealer, 1, BUYER
    from STORERETAIL
    where NUM = @num and CLS = @cls
  if @@error <> 0
  begin
    select @msg = '复制BUY1错误'
    return(1)
  end

  insert into BUY11(FLOWNO, POSNO, ITEMNO, SETTLENO, CURRENCY, AMOUNT, TAG, CARDCODE)
    select @FLOWNO, @posno, ITEMNO, @SETTLENO, CURRENCY, AMOUNT, TAG, CARDNUM
    from STORERETAILCURDTL
    where NUM = @num and CLS = @cls
  if @@error <> 0
  begin
    select @msg = '复制BUY11错误'
    return(1)
  end

  insert into BUY2(FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, PRICE, REALAMT, FAVAMT, QPCGID, PRMTAG,
    ASSISTANT, WRH, DEALER, COST)
    select @FLOWNO, @posno, LINE, @settleno, GdGid, BuyerOrderQty, Inprc, RtlPrc, Total, FavAmt, QpcGid, PrmTag,
      SellerAssistant, SenderWrh, @dealer, COST
    from STORERETAILDTL
    where NUM = @num AND CLS = @cls
  if @@error <> 0
  begin
    select @msg = '复制BUY2错误'
    return(1)
  end

  insert into BUY21(FLOWNO, POSNO, ITEMNO, FAVTYPE, SETTLENO, FAVAMT, TAG)
    select @FLOWNO, @POSNO, ITEMNO, FAVTYPE, @settleno, FAVAMT, TAG
    from STORERETAILFAVDTL
    where NUM = @num and CLS = @cls
  if @@error <> 0
  begin
    select @msg = '复制BUY21错误'
    return(1)
  end


  exec COPYTOPREORDPOOL @posno, @flowno

  update preordpooldtl set remark = srdtl.remark
  from STORERETAILDTL srdtl(nolock) where srdtl.num = @NUM and srdtl.cls = @CLS  and preordpooldtl.flowno = @flowno
  and preordpooldtl.POSNO = @posno
  and srdtl.gdgid *= preordpooldtl.gdgid

  update preordpool set MEMO = sr.remark
  from STORERETAIL sr(nolock) where sr.NUM = @NUM and sr.cls = @cls

  update STORERETAIL SET FLOWNO = @flowno
   where NUM = @NUM and CLS = @CLS
  return(0)
end
GO
