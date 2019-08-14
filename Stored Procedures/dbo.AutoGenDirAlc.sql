SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AutoGenDirAlc]
(
  @piCur_Num char(14),
  @poMSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
  DECLARE  @Num char(14),   @Cls char(20),
    @SettleNo int,          @PriceType char(20),
    @InPrcTax int,          @KeepSame varchar(30),
    @outprc money,          @gdgid int,
    @wrh int,               @line int,
    @storegid int,          @Total money,
    @Tax money,             @AlcTotal money,
    @DirAlcWrh int,         @ret int,
    @ErrGdCode varchar(13),
    @AutoGenBckBillGetWrhMethod int,
    @AutoGenBckBill_UseSameDtlWrh int
  SET @Cls = '直配进退'
  SELECT @Num = right(max(num)+10000000001,10) from DirAlc where cls = @Cls
  IF @Num IS NULL  SET @Num = '0000000001'
  SELECT @SettleNo =  max(no) from MONTHSETTLE
  --根据HDOPIOTN取得PriceType
  EXEC OPTREADINT 43, 'pricetype', 0, @PriceType OUTPUT
  EXEC OPTREADINT 569, 'AutoGenBckBillGetWrhMethod', 0, @AutoGenBckBillGetWrhMethod OUTPUT
  EXEC OPTREADINT 569, 'AutoGenBckBill_UseSameDtlWrh', 0, @AutoGenBckBill_UseSameDtlWrh OUTPUT
  SET @DirAlcWrh = 1
  IF @AutoGenBckBillGetWrhMethod = 0
    SELECT @DirAlcWrh = DirAlcWrh FROM [system]
  IF @DirAlcWrh = 1 OR @AutoGenBckBillGetWrhMethod = 1
  BEGIN
      SELECT TOP 1 @DirAlcWrh = GD.WRH
      FROM VDRBCKDMDDTL DTL, GOODS GD(NOLOCK) WHERE NUM = @piCur_Num AND GD.GID = DTL.GDGID
  END
  SELECT TOP 1 @ErrGdCode = GD.CODE FROM VDRBCKDMDDTL DTL(NOLOCK), GOODS GD(NOLOCK)
            WHERE NUM = @piCur_Num AND GD.GID = DTL.GDGID AND GD.WRH = 1
  IF (@ErrGdCode IS NOT NULL) OR (RTRIM(@ErrGdCode) <> '') OR (@DirAlcWrh = 1)
  BEGIN
    SET @poMSG = '存在供应商退货申请单['+@piCur_Num+']'+char(13)
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
  END

  --插入明细 2004.12.31
  INSERT INTO DirAlcDtl (CLS, NUM, LINE, GDGID, SETTLENO, WRH, QTY, CASES, PRICE, TOTAL, TAX, ALCPRC, ALCAMT, WSPRC, INPRC, RTLPRC, NOTE)
    SELECT  @Cls CLS, @Num NUM, LINE, GDGID, @SettleNo SETTLENO, 0 WRH, QTY, CASES, ISNULL(PRICE,0), 0 TOTAL, 0 TAX, 0 ALCPRC, 0 ALCAMT, 0 WSPRC, 0 INPRC, 0 RTLPRC, NOTE
    FROM VDRBCKDMDDTL where NUM = @piCur_Num

  -- 更新 DIRALCDTL 中的inprc,rtlprc,wrh,wsprc
  UPDATE DIRALCDTL
    SET inprc = b.inprc, rtlprc = b.rtlprc, wrh = b.wrh, wsprc = b.whsprc
    FROM DIRALCDTL a, goods b
    WHERE a.gdgid = b.gid and a.num = @Num and a.Cls = @Cls
  IF @AutoGenBckBill_UseSameDtlWrh = 1
    UPDATE DIRALCDTL SET WRH = @DIRALCWRH WHERE NUM = @NUM AND CLS = @CLS

  -- 更新 DIRALCDTL 中的price 2004.12.31 DIRALCDTL.price<=0
        EXEC('UPDATE DIRALCDTL SET price = b.' + @PriceType +
    ' FROM DIRALCDTL a, goods b WHERE a.price<=0 and a.gdgid = b.gid AND A.CLS = '''+@CLS+''' AND a.num ='''+@Num+'''')

  --是否去税
  SELECT @InPrcTax = inprctax FROM [system]

  IF @InPrcTax = 1
  BEGIN
    -- 更新 DIRALCDTL 中的total
    UPDATE DIRALCDTL
    SET total = round(price * qty, 2)
    WHERE num = @Num AND CLS = @CLS

    --更新 DIRALCDTL 中的tax
    UPDATE DIRALCDTL
    SET tax = a.total - round(a.total / (1+ (b.taxrate/100)), 2)
    FROM DIRALCDTL a, goods b
    WHERE a.gdgid = b.gid and a.num = @Num AND CLS = @CLS
  END
  ELSE BEGIN
    --更新 DIRALCDTL 中的tax
    UPDATE DIRALCDTL
    SET tax = round(qty*(
      a.price - a.price /(1+ (gd.taxrate/100))
      ),2) --4->2 2006-01-23
    FROM goods gd(nolock) , diralcdtl a
    WHERE gd.gid = a.gdgid and a.num = @Num AND CLS = @CLS
    -- 更新 DIRALCDTL 中的total
    UPDATE DIRALCDTL
    SET total = round(a.price /(1+ (b.taxrate/100)) * qty, 2)
    FROM DIRALCDTL a, goods b
    WHERE a.gdgid = b.gid and a.num = @Num AND CLS = @CLS
    --去税则重算price
    --2005.01.01 注释因为直接从VDRBCKDMDDTL中得到的价格
    /*UPDATE DIRALCDTL
    SET price = round(a.price /(1+ (b.taxrate/100)), 2)
    FROM DIRALCDTL a, goods b
    WHERE a.gdgid = b.gid and a.num = @Num AND CLS = @CLS*/
  END

  --从 HDOPTION 中取@Keepsame
  EXEC OPTREADSTR 88, 'chkoption', '', @KeepSame OUTPUT
  SELECT @storegid = dmdstore from vdrbckdmd where num = @piCur_Num
  IF SUBSTRING(@KeepSame, 17, 1) = '1'
  BEGIN
    UPDATE DIRALCDTL set alcprc = price where num = @Num AND CLS = @CLS
  END ELSE
  BEGIN
    DECLARE diralcdtl_cursor cursor for
      SELECT gdgid, wrh, line
      FROM diralcdtl
      WHERE num = @num and cls = @cls
    OPEN diralcdtl_cursor
    FETCH next from diralcdtl_cursor into @gdgid, @wrh, @line
    WHILE @@fetch_status =0
    BEGIN
      EXEC @ret= getstoreoutprc @storegid, @gdgid, @wrh, @outprc output
      IF @ret<>0
      BEGIN
        SET @poMSG = '取出货单价的时候发生异常'
        CLOSE diralcdtl_cursor
        DEALLOCATE diralcdtl_cursor
        RETURN 1
      END
      UPDATE diralcdtl
      SET alcprc = @outprc
      WHERE cls = @cls AND num = @num AND line = @line
      FETCH NEXT from diralcdtl_cursor INTO @gdgid, @wrh, @line
    END
    CLOSE diralcdtl_cursor
    DEALLOCATE diralcdtl_cursor
  END
  --计算 diralcdtl 中alcamt和outtax
  UPDATE diralcdtl set alcamt = qty * alcprc where num = @num

  UPDATE DIRALCDTL
  SET outtax = a.alcamt - round(a.alcamt / (1+ (b.taxrate/100)), 2)
  FROM DIRALCDTL a, goods b
  WHERE a.gdgid = b.gid and a.num = @Num AND CLS = @CLS

  --插入主表
  INSERT INTO DirAlc (CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, PSR, TOTAL,
      TAX, ALCTOTAL, SRC, RECCNT, NOTE, FROMCLS, FROMNUM)
    SELECT @Cls CLS, @Num NUM, @SETTLENO SETTLENO, VENDOR, CHKSTOREGID, DMDSTORE, PSRGID, 1 TOTAL,
      0 TAX, 0 ALCTOTAL, DMDSTORE, RECCNT, '由供应商退货申请单['+@piCur_Num+']导入：'+NOTE,
      '供应商退货申请单', @piCur_num
    FROM vdrbckdmd
    WHERE NUM = @piCur_Num

  --和计 DIRALC 表中TOTAL,TAX,ALCTOTAL
  SELECT @Total = SUM(total), @Tax = SUM(tax),@AlcTotal = SUM(qty * AlcPrc)
  FROM DIRALCDTL
  WHERE num = @Num AND CLS = @CLS

  --更新 DIRALC 中的TOTAL, TAX, ALCTOTAL, WRH
  UPDATE DIRALC
  SET TOTAL = @Total, TAX = @Tax, ALCTOTAL = @ALCTOTAL, WRH = @DirAlcWrh
  WHERE NUM = @Num and CLS = @Cls

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

  --更新 DIRALC 中的 FILLER,PSR
  UPDATE DIRALC
  SET FILLER = @FILLER  --, PSR = @DMDPSR 2005.01.12
  WHERE  num = @Num AND cls = @Cls

  SET @poMSG = '自动生成单号为'+@Num+'的直配进货退货单'

  --回写vdrbckdmd
  UPDATE vdrbckdmd
  SET locknum = @Num, lockcls = @Cls
  WHERE num = @piCur_Num
END
GO
