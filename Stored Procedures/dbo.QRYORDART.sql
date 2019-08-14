SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[QRYORDART]
(
  @strOrdNum varchar(14),          --定货单单号
  @strGdInput varchar(40),         --商品条码
  @strGdName varchar(100) output,  --商品名称
  @curGdQpc decimal(24,4) output,  --商品QPC
  @OrdQtyStr varchar(4000) output, --定货件数 (根据ORDDTL.QTY计算而来。格式：A.B。 A表示箱数，B表示数量中除去A箱外的拆零数。)
  @RcvQtyStr varchar(4000) output, --已收数量 (根据ORDDTL.ARVQTY + 已审核收货单数量 + 本次收货数量计算而来。格式：A.B。
                                   --A表示箱数，B表示数量中除去A箱外的拆零数)
  @strErrMsg varchar(4000) output  --返回错误信息，当返回值不等于0时有效
) AS
BEGIN
  DECLARE
    @intGdgid int, --商品GID
    @strMunit varchar(40),
    @NotArvQtyStr varchar(4000),
    @ret int, --返回值
    @curOrdPrc decimal(24,4)

  --不管是否为大包装商品，将条码转基本商品条码
  EXEC @ret = PKGTOBASICINPUT @strInputCode = @strGdInput, @strBasicGdCode = @strGdInput OUTPUT,
    @intBasicGdGid = @intGdgid OUTPUT, @strErrMsg = @strErrMsg OUTPUT;
  IF @ret <> 0
  BEGIN
    RETURN(1);
  END;

  --取商品的QPC
  SELECT @curGdQpc = QPC
  FROM GOODS(NOLOCK)
  WHERE GID = @intGdgid;

  --取商品收货信息
  EXEC @ret = chkArticle
    @piOrdNum = @strOrdNum,
    @piInputGdCode = @strGdInput,
    @poNameSpec = @strGdName OUTPUT,
    @poQpc = @curGdQpc OUTPUT,
    @poMunit = @strMunit OUTPUT,
    @poOrdQtyStr = @OrdQtyStr OUTPUT,
    @poArvQtyStr = @RcvQtyStr OUTPUT,
    @poNotArvQtyStr = @NotArvQtyStr OUTPUT,
    @poPrice = @curOrdPrc OUTPUT,
    @poErrMsg = @strErrMsg OUTPUT;
  IF @ret <> 0
  BEGIN
    SELECT @strErrMsg = '取定单收货信息错误：' + @strErrMsg;
    RETURN(1);
  END;

  --返回商品收货记录(进货单号、收货人、收货件数、收货规格、收货数量)
  SELECT M.NUM 收货单号, RTRIM(E.NAME) + '[' + RTRIM(E.CODE) + ']' 收货人,  CAST(ROUND(D.GDQTY/@curGdQpc, 4) AS DECIMAL(24,4)) 收货箱数, @curGdQpc 包装规格, D.GDQTY 收货数量
  FROM  GOODSRECEIPTDTL D(NOLOCK), GOODSRECEIPT M(NOLOCK)
    LEFT JOIN EMPLOYEE E(NOLOCK) ON M.RECEIVER =  E.GID
  WHERE M.SRCORDNUM = @strOrdNum
    AND ((M.STAT = 100) OR (M.STAT = 300) OR (M.STAT = 0))
    AND D.NUM = M.NUM
    AND D.GDGID = @intGdGid

  RETURN(0);
END;
GO
