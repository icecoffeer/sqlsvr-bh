SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[updStkin]
(
  @strReceiptNum char(14),        --收货单号
  @strGdInput VARCHAR(13),        --商品条码
  @strQty varchar(100),           --收货件数。传入的小数点前表示箱数，小数点后表示拆零数。收货总数量为箱数*qpc + 拆零数。但当qpc为1时，小数点前后均表示数量。
  @strUserCode VARCHAR(10),       --操作员代码
  @dtPrdDate DATETIME,            --生产日期
  @curPrice decimal(24,4),        --单价
  @intIsFastRcv int,              --是否快收。0-否；1-是。
  @strErrMsg VARCHAR(255) OUTPUT  --返回错误信息，当返回值不等于0时有效
) AS
BEGIN
  DECLARE
    @OPER VARCHAR(30),
    @GDGID INT,
    @GdQpc DECIMAL(24, 4),        --商品qpc，算数量用
    @GdValidPeriod int,           --商品保质期（天数）
    @LEFTQTY DECIMAL(24, 4),      --本次收货数量
    @RCVQTY DECIMAL(24, 4),       --已收货数量
    @ORDQTY DECIMAL(24, 4),
    @RECEIPTQTY DECIMAL(24, 4),
    @LINE INT,
    @curOrdQty DECIMAL(24, 4),
    @curArvQty DECIMAL(24, 4),
    @curReceiptQty DECIMAL(24, 4),
    @strOrdNum varchar(14),
    @ret int,
    @dtCurPrdDate DATETIME,       --更新进收货单的生产日期。如果为空则不更新，非空才更新
    @AbsLeftQty DECIMAL(24, 4),   --收货数量的绝对值
    @RemainOrdQty DECIMAL(24, 4), --未收货数量
    @SIGN int,                    --正负符号
    @ARVQTY DECIMAL(24, 4),       --定货单明细：到货数
    @d_ReceiptQty DECIMAL(24, 4), --定货单明细：到货数
    @d_GdQty DECIMAL(24, 4),      --收货单明细：收货数
    @Flag int,                    --定单明细：赠品标识
    @MaxOrdPrc decimal(24,4),     --最大定货单价
    @opt_ChkValidPeriod int,      --选项，是否校验保质期（为1时，客户端须填写生产日期）
    @opt_AllowRcvOverOrd int      --选项，是否允许收货数大于定单定货数？0（默认）-否；1-是。

  --读取选项。
  EXEC OPTREADINT 8146, 'Ord_Rcv_Chk_Valid_Period', 0, @opt_ChkValidPeriod OUTPUT
  EXEC OPTREADINT 8146, 'Ord_Rcv_Allow_Rcv_Over_Ord', 0, @opt_AllowRcvOverOrd OUTPUT

  --不管是否为大包装商品，将条码转基本商品条码
  EXEC @ret = PKGTOBASICINPUT @strInputCode = @strGdInput,
    @strBasicGdCode = @strGdInput OUTPUT,
    @intBasicGdGid = @GDGID OUTPUT,
    @strErrMsg = @strErrMsg OUTPUT;
  IF @ret <> 0
  BEGIN
    RETURN(1);
  END;

  --获取商品信息
  SELECT @GdQpc = QPC, @GdValidPeriod = ISNULL(VALIDPERIOD, 0)
    FROM GOODS(NOLOCK)
    WHERE GID = @GDGID;

  /*由于管理保质期（到效期）的商品必须要求填写生产日期（到效期），而客户端在快收
  时无法填写生产日期（到效期），因此限制当所收为管理保质期（到效期）的商品时，则
  不允许快收。*/
  IF @opt_ChkValidPeriod = 1 AND @GdValidPeriod > 0 AND @intIsFastRcv = 1
  BEGIN
    SET @strErrMsg = '当前商品为管理保质期的商品，不能快收'
    RETURN(1);
  END;

  /*处理生产日期。无论用户是否在客户端填写生产日期，@dtPrdDate总是有值的，故须
  对其值进行处理后再使用。*/
  IF @opt_ChkValidPeriod <> 1
  BEGIN
    SET @dtPrdDate = NULL;
  END;

  --计算本次收货数量
  SET @LEFTQTY = dbo.StrToQty(@strQty, @GdQpc)
  IF @LEFTQTY = 0
  BEGIN
    RETURN(0)
  END;

  --操作人
  SELECT @OPER = RTRIM(NAME) + '[' + RTRIM(CODE) + ']'
    FROM EMPLOYEE(NOLOCK)
    WHERE CODE = @strUserCode
  IF @@ROWCOUNT = 0
  BEGIN
    SET @strErrMsg = '操作员代码' + RTRIM(ISNULL(@strUserCode, '')) + '在员工表中不存在。'
    RETURN(1);
  END;

  --定货单号
  SELECT @strOrdNum = SRCORDNUM
    FROM GOODSRECEIPT(NOLOCK)
    WHERE NUM = @strReceiptNum;

  --定单：定货数，到货数，最大单价
  SELECT @curOrdQty = ISNULL(SUM(QTY), 0),
    @curArvQty = ISNULL(SUM(ARVQTY), 0),
    @MaxOrdPrc = ISNULL(MAX(PRICE), 0)
  FROM ORDDTL (NOLOCK)
  WHERE NUM = @strOrdNum
    AND GDGID = @GDGID

  --传入的单价不能大于最大定货单价
  SET @curPrice = ISNULL(@curPrice, 0)
  IF @curPrice > @MaxOrdPrc
  BEGIN
    SET @strErrMsg = '单价不能大于' + CONVERT(VARCHAR, @MaxOrdPrc)
    RETURN(1);
  END
  ELSE IF @curPrice < 0
  BEGIN
    SET @strErrMsg = '单价不能小于0'
    RETURN(1);
  END

  --查询定货单的所有收货单(状态为非已完成)中该商品的收货数量之和
  SELECT @curReceiptQty = SUM(D.GDQTY)
  FROM GOODSRECEIPTDTL D(NOLOCK), GOODSRECEIPT M(NOLOCK)
  WHERE M.NUM = D.NUM
    AND M.NUM = @strReceiptNum
    AND M.SRCORDNUM = @strOrdNum
    AND M.STAT IN (0, 1600, 100)
    AND D.GDGID = @GDGID;

  --如果收货数量大于应收数量，则不允许收货
  IF @opt_AllowRcvOverOrd = 0 AND @LEFTQTY + @curArvQty + @curReceiptQty > @curOrdQty
  BEGIN
    SELECT @strErrMsg = '收货数量大于应收数量，不能收货';
    RETURN(1);
  END;

  --如果收货数量小于0，则不允许收货
  IF @LEFTQTY + @curArvQty + @curReceiptQty < 0
  BEGIN
    SELECT @strErrMsg = '收货数量小于0，不能收货';
    RETURN(1);
  END;

  --本次收货数量的绝对值
  IF @LEFTQTY >= 0
    SELECT @SIGN = 1
  ELSE
    SELECT @SIGN = -1
  SELECT @ABSLEFTQTY = ABS(@LEFTQTY)

  /*
  更新收货数
  1.因定单中由于赠品原因有可能有两条一样的商品，以下按行号依次匹配收货数
  2.排序方式：先按定单明细赠品标识降序排列，先赠品，后正常品，这样客户可以得到实惠
    再按行号升序排列
  */
  DECLARE C_GOODSRECEIPTDTL CURSOR FOR
    SELECT R.LINE, R.GDQTY, O.ARVQTY, O.QTY, O.FLAG, R.PRDDATE
    FROM GOODSRECEIPTDTL R(NOLOCK), GOODSRECEIPT RM(NOLOCK), ORDDTL O(NOLOCK)
    WHERE R.NUM = RM.NUM
    AND RM.SRCORDNUM = O.NUM
    AND R.LINE = O.LINE
    AND RM.NUM = @strReceiptNum
    AND R.GDGID = @GDGID
    ORDER BY O.FLAG DESC, O.LINE;
  OPEN C_GOODSRECEIPTDTL
  FETCH NEXT FROM C_GOODSRECEIPTDTL INTO @LINE, @d_GdQty, @ARVQTY, @ORDQTY, @FLAG, @dtCurPrdDate
  WHILE @@FETCH_STATUS = 0
  BEGIN
    --如果不是赠品，则更新收货单价
    IF @FLAG = 0
    BEGIN
      UPDATE GOODSRECEIPTDTL SET
        PRICE = @curPrice
        WHERE NUM = @strReceiptNum
        AND LINE = @LINE
    END

    --该行商品的已收货数量之和
    SELECT @D_RECEIPTQTY = SUM(D.GDQTY)
      FROM GOODSRECEIPTDTL D(NOLOCK), GOODSRECEIPT M(NOLOCK)
      WHERE M.NUM = D.NUM
      AND M.NUM = @strReceiptNum
      AND M.SRCORDNUM = @strOrdNum
      AND M.STAT IN (0, 1600, 100)
      AND D.LINE = @LINE
      AND D.GDGID = @GDGID;

    --定货单：该行商品已收货数量之和
    SELECT @RCVQTY = @ARVQTY + @D_RECEIPTQTY

    --定货单上该行商品的待收货数量
    SELECT @REMAINORDQTY = @ORDQTY - @RCVQTY
    IF @REMAINORDQTY < 0
      SELECT @REMAINORDQTY = 0

    --该行商品分配到的收货数量
    IF @SIGN = 1
    BEGIN
      IF @ABSLEFTQTY >= @REMAINORDQTY
        SELECT @RECEIPTQTY = @REMAINORDQTY * @SIGN;
      ELSE
        SELECT @RECEIPTQTY = @ABSLEFTQTY * @SIGN
    END
    ELSE IF @SIGN = -1
    BEGIN
      IF @d_GdQty > 0
      BEGIN
        IF @ABSLEFTQTY >= @d_GdQty
          SELECT @RECEIPTQTY = @d_GdQty * @SIGN;
        ELSE
          SELECT @RECEIPTQTY = @ABSLEFTQTY * @SIGN
      END
      ELSE
        SELECT @RECEIPTQTY = 0
    END

    --该行商品本次收货数为0，则跳过
    IF @RECEIPTQTY = 0
      GOTO NEXTLOOP

    --更新生产日期，同一个商品取最小的生产日期
    IF @dtPrdDate IS NOT NULL AND (@dtCurPrdDate IS NULL OR @dtCurPrdDate > @dtPrdDate)
    BEGIN
      UPDATE GOODSRECEIPTDTL
        SET PRDDATE = @dtPrdDate
        WHERE NUM = @strReceiptNum
        AND LINE = @LINE
        AND GDGID = @GDGID;
    END;

    --更新收货数量
    IF @RECEIPTQTY <> 0
      UPDATE GOODSRECEIPTDTL
        SET GDQTY = GDQTY + @RECEIPTQTY
        WHERE NUM = @strReceiptNum
        AND LINE = @LINE
        AND GDGID = @GDGID;

    --更新本次收货数量，减去已分配的部分
    SELECT @ABSLEFTQTY = @ABSLEFTQTY - ABS(@RECEIPTQTY);

NEXTLOOP:
    FETCH NEXT FROM C_GOODSRECEIPTDTL INTO @LINE, @d_GdQty, @ARVQTY, @ORDQTY, @FLAG, @dtCurPrdDate
  END;
  CLOSE C_GOODSRECEIPTDTL
  DEALLOCATE C_GOODSRECEIPTDTL

  --本次收货数量的绝对值如果大于0，则分摊到最后一条满足条件商品上
  IF @ABSLEFTQTY > 0
  BEGIN
    SELECT @LINE = MAX(LINE)
      FROM GOODSRECEIPTDTL R(NOLOCK)
      WHERE R.NUM = @strReceiptNum
      AND R.GDGID = @GDGID
    IF @LINE IS NOT NULL
      UPDATE GOODSRECEIPTDTL
        SET GDQTY = GDQTY + @ABSLEFTQTY * @SIGN
        WHERE NUM = @strReceiptNum
        AND LINE = @LINE
        AND GDGID = @GDGID;
  END

  UPDATE GOODSRECEIPT
    SET LSTUPDOPER = @OPER, LSTUPDTIME = GETDATE()
    WHERE NUM = @strReceiptNum
  RETURN(0)
END
GO
