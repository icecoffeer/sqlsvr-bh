SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[QRYORD]
(
  @strOrdNum varchar(14),           --定货单单号
  @currUnArvQty money OUTPUT,       --定单中所有商品尚未收货的总数量
  @curArvqty money OUTPUT,          --定单中所有商品已经收货的总数量
  @strErrMsg varchar(4000) OUTPUT   --返回错误信息，当返回值不等于0时有效
)AS
BEGIN
  DECLARE
    @ReceiptQty money;

  SELECT @curArvqty = ISNULL(SUM(ARVQTY), 0),
    @currUnArvQty = ISNULL(SUM(QTY - ARVQTY), 0)
  FROM ORDDTL (NOLOCK)
  WHERE NUM = @strOrdNum
  GROUP BY NUM;

  --查询未审核收货单的已收货数量
  SELECT @ReceiptQty = ISNULL(SUM(GDQTY), 0)
  FROM GOODSRECEIPTDTL D(NOLOCK), GOODSRECEIPT M(NOLOCK)
  WHERE M.NUM = D.NUM
    AND M.SRCORDNUM = @strOrdNum
    AND M.STAT = 0;

  SELECT @curArvqty = @curArvqty + @ReceiptQty;
  SELECT @currUnArvQty = @currUnArvQty - @ReceiptQty;

  RETURN(0);
END;
GO
