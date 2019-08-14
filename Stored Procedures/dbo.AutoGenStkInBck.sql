SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AutoGenStkInBck]
(
  @piCur_Num char(14),
  @poMSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
  DECLARE  @Num char(14),   @Cls char(20),
    @SettleNo int,          @PriceType char(20),
    @InPrcTax int,          @Total money,
    @Tax money,             @AlcWrh int,
    @AutoGenBckBillGetWrhMethod int,
    @AutoGenBckBill_UseSameDtlWrh int,
    @ErrGdCode varchar(13)

  SET @Cls = '配货'
  SELECT @Num = RIGHT( Max(Num)+10000000001,10) FROM Stkinbck WHERE Cls = @Cls
  IF @Num IS NULL  SET @Num = '0000000001'
  SELECT @SettleNo =  MAX(No) FROM MonthSettle
    --根据 HDOPIOTN 取得PriceType
  EXEC OPTREADINT 43, 'pricetype', 0, @PriceType OUTPUT
  EXEC OPTREADINT 518, 'AutoGenBckBillGetWrhMethod', 0, @AutoGenBckBillGetWrhMethod OUTPUT
  EXEC OPTREADINT 518, 'AutoGenBckBill_UseSameDtlWrh', 0, @AutoGenBckBill_UseSameDtlWrh OUTPUT
  SET @AlcWrh = 1
  IF @AutoGenBckBillGetWrhMethod = 0
    SELECT @AlcWrh = ALCWRH FROM [system]
  IF @ALCWRH = 1 OR @AutoGenBckBillGetWrhMethod = 1
  BEGIN
    SELECT TOP 1 @ALCWRH = GD.WRH
      FROM BCKDMDDTL DTL, GOODS GD(NOLOCK) WHERE NUM = @piCur_Num AND GD.GID = DTL.GDGID
  END
  SELECT TOP 1 @ErrGdCode = GD.CODE FROM BCKDMDDTL DTL(NOLOCK), GOODS GD(NOLOCK)
             WHERE NUM = @piCur_Num AND GD.GID = DTL.GDGID AND GD.WRH = 1
  IF (@ErrGdCode IS NOT NULL) OR (RTRIM(@ErrGdCode) <> '') OR (@AlcWrh = 1)
   BEGIN
     SET @poMSG = '存在配货退货申请单['+@piCur_Num+']'+char(13)
         +'商品['+@ErrGdCode+']是未知仓位商品'+char(13)
         +'处理终止，请确认该商品资料后重新接收'
     RETURN 1
   END
  SELECT @PriceType =
    CASE @PriceType
      WHEN '0' THEN    'LSTINPRC'
      WHEN '1' THEN    'INPRC'
      WHEN '2' THEN    'RTLPRC'
      WHEN '3' THEN    'CNTINPRC'
      WHEN '4' THEN    'WHSPRC'
      WHEN '5' THEN    'INVPRC'
      WHEN '6' THEN    'LWTRTLPRC'
      WHEN '7' THEN    'OLDINVPRC'
      WHEN '8' THEN    'MBRPRC'
      WHEN '9' THEN    'MKTINPRC'
      WHEN '10' THEN   'MKTRTLPRC'
      ELSE 'INPRC'
    end
  --插入明细
  INSERT INTO StkinBckDtl (
      CLS, NUM, LINE, GDGID, SETTLENO, QTY,
      PRICE, TOTAL, TAX, INPRC, RTLPRC, CASES, NOTE)
    SELECT @Cls CLS, @Num NUM, LINE, GDGID, @SettleNo SETTLENO, QTY,
      0 PRICE, 0 TOTAL, 0 TAX, 0 INPRC, 0 RTLPRC, CASES, NOTE
    FROM BCKDMDDTL
    WHERE  NUM = @piCur_Num

  -- 更新 StkinBckDtl 中的inprc,rtlprc,wrh
  UPDATE stkinbckdtl
    SET inprc = b.inprc, rtlprc = b.rtlprc, wrh = b.wrh
    FROM stkinbckdtl a, goods b
    WHERE a.gdgid = b.gid and a.num = @Num and Cls = @Cls
  IF @AutoGenBckBill_UseSameDtlWrh = 1
    UPDATE STKINBCKDTL SET WRH = @ALCWRH WHERE NUM = @NUM AND CLS = @CLS
  -- 更新 StkinBckDtl 中的price
  EXEC(' UPDATE stkinbckdtl SET price = b.'
    + @PriceType + ' FROM stkinbckdtl a, goods b WHERE a.gdgid = b.gid AND A.CLS = '''+@CLS+''' AND a.num ='''+@Num+''' ')
  --是否去税
  SELECT @InPrcTax = inprctax FROM [system]
  IF @InPrcTax = 1
  BEGIN
    -- 更新 StkinBckDtl 中的total
    UPDATE stkinbckdtl
    SET total = price * qty
    WHERE num = @Num AND CLS = @CLS
    --更新 StkinBckDtl 中的tax
    UPDATE stkinbckdtl
    SET tax = a.total - round(a.total/(1+ (b.taxrate/100)), 4)
    FROM stkinbckdtl a, goods b
    WHERE a.gdgid = b.gid and a.num = @Num AND A.CLS = @CLS
  END ELSE
  BEGIN
    --更新 StkinBckDtl 中的tax
    UPDATE stkinbckdtl
    SET tax = round(qty*(
      a.price - a.price /(1+ (gd.taxrate/100))
      ),4)
    FROM goods gd(nolock) , stkinbckdtl a
    WHERE gd.gid = a.gdgid AND a.num = @Num AND A.CLS = @CLS
    -- 更新 StkinBckDtl 中的total
    UPDATE stkinbckdtl
    SET total =round(price /(1+ (taxrate/100)) * qty, 4)
    FROM stkinbckdtl a, goods b
    WHERE a.gdgid = b.gid AND a.num = @Num AND A.CLS = @CLS
    --去税则重算price
    UPDATE stkinbckdtl
    SET price = round(price /(1+ (taxrate/100)), 4)
    FROM stkinbckdtl a, goods b
    WHERE a.gdgid = b.gid AND a.num = @Num AND A.CLS = @CLS
  END

  --插入主表
  INSERT INTO StkInBck (CLS, NUM, SETTLENO, SRC, PSR, RECCNT, VENDOR,
            BILLTO, OCRDATE, FILDATE, STAT, NOTE, GENCLS, GENNUM)
    SELECT @Cls CLS, @Num NUM, @SettleNo SETTLENO, SRC, PSRGID, RECCNT, CHKSTOREGID,
            CHKSTOREGID, GETDATE() OCRDATE, GETDATE() FILDATE, 0 STAT,
            '由配货退货申请单['+@piCur_Num+']导入：'+NOTE, '配货退货申请单', @piCur_Num
    FROM BCKDMD
    WHERE NUM = @piCur_Num

  --和计 StkInBck 表中TOTAL,TAX
  SELECT @Total = sum(total), @Tax = sum(tax)
  FROM stkinbckdtl
  WHERE num = @Num AND CLS = @CLS

  --更新 StkInBck 中的TOTAL, TAX, WRH
  UPDATE stkinbck
    SET total = @Total, tax = @Tax, WRH = @AlcWrh
    WHERE num = @Num and cls = @Cls

  --取得当前用户
  DECLARE @FILLERCODE VARCHAR(20), @FILLER INT, @FILLERNAME VARCHAR(50)
  SET @FILLERCODE = RTRIM(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
  SELECT @FILLER = GID, @FILLERNAME = NAME FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
  IF @FILLERNAME IS NULL
  BEGIN
    SET @FILLERCODE = '-'
    SET @FILLERNAME = '未知'
  END
  SET @FILLERCODE = CONVERT(VARCHAR(30), '['+RTRIM(ISNULL(@FILLERCODE,''))+']' + RTRIM(ISNULL(@FILLERNAME,'')))

  --更新 StkInBck 中的 FILLER,PSR
  UPDATE stkinbck
  SET FILLER = @FILLER  --, PSR = @FILLER 2005.01.12
  WHERE  num = @Num and cls = @Cls

  SET @poMSG = '自动生成单号为'+@Num+'的配货进货退货单'

  --回写 bckdmd
    UPDATE bckdmd
    SET locknum = @Num, lockcls = '配进退', STAT = 300
    WHERE num = @piCur_Num
END
GO
