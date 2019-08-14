SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AutoGenStkoutBckbyCases]
(
  @piCur_Num char(14),
  @poMSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE  @Num char(14),   @Cls char(20),
    @SettleNo int,          @PriceType char(20),
    @InPrcTax int,          @Total money,
    @Tax money,             @AlcWrh int,
    @AutoGenBckBillGetWrhMethod int,
    @AutoGenBckBill_UseSameDtlWrh int,
    @ErrGdCode varchar(13),
    --ShenMin
    @CaseNum char(14),      @Line int,
    @Cases money,           @Qty money,
    @PreCaseNum char(14),
    @gdgid int

  SET @Cls = '配货'
  SELECT @Num = RIGHT( Max(Num)+10000000001,10) FROM StkoutBck WHERE Cls = @Cls
  IF @Num IS NULL  SET @Num = '0000000001'
  SELECT @SettleNo =  MAX(No) FROM MonthSettle
    --根据 HDOPIOTN 取得PriceType
  EXEC OPTREADINT 43, 'pricetype', 0, @PriceType OUTPUT
  EXEC OPTREADINT 518, 'AutoGenBckBillGetWrhMethod', 0, @AutoGenBckBillGetWrhMethod OUTPUT
  EXEC OPTREADINT 518, 'AutoGenBckBill_UseSameDtlWrh', 0, @AutoGenBckBill_UseSameDtlWrh OUTPUT
  SET @AlcWrh = 1
  IF @AutoGenBckBillGetWrhMethod = 0
    SELECT @AlcWrh = ALCWRH FROM [system]
  IF  @AutoGenBckBillGetWrhMethod = 1   --@ALCWRH = 1 OR
  BEGIN
    SELECT TOP 1 @ALCWRH = GD.WRH
      FROM BCKDMDDTL DTL, GOODS GD(NOLOCK) WHERE NUM = @piCur_Num AND GD.GID = DTL.GDGID
  END
  SELECT TOP 1 @ErrGdCode = GD.CODE FROM BCKDMDDTL DTL(NOLOCK), GOODS GD(NOLOCK)
             WHERE NUM = @piCur_Num AND GD.GID = DTL.GDGID AND GD.WRH = 1
  IF (@ErrGdCode IS NOT NULL) OR (RTRIM(@ErrGdCode) <> '') --OR (@AlcWrh = 1)
   BEGIN
     SET @poMSG = '存在配货退货申请单['+@piCur_Num+']'+char(13)
         +'商品['+@ErrGdCode+']是未知仓位商品'+char(13)
         +'处理终止，请确认该商品资料后重新接收'
     RETURN 2
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

                --取得当前用户
              DECLARE @FILLERCODE VARCHAR(20), @FILLER INT, @FILLERNAME VARCHAR(50)
              SET @FILLERCODE = RTRIM(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
              SELECT @FILLER = GID, @FILLERNAME = NAME FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
              IF @FILLERNAME IS NULL
              BEGIN
                SET @FILLERCODE = '-'
                SET @FILLERNAME = '未知'
                SET @FILLER = 1
              END
              SET @FILLERCODE = CONVERT(VARCHAR(30), '['+RTRIM(ISNULL(@FILLERCODE,''))+']' + RTRIM(ISNULL(@FILLERNAME,'')))

  --设置初始值
  set @PreCaseNum = ''
  set @line = 0

  declare c_BckDmdDtlDtl cursor for
    select CASENUM, GDGID, CASES, QTY  --, LINE
    from BCKDMDDTLDTL(nolock) where NUM = @piCur_Num
    ORDER BY CASENUM
  open c_BckDmdDtlDtl
  fetch next from c_BckDmdDtlDtl into
    @CaseNum, @gdgid, @Cases, @Qty  --, @Line

  while @@fetch_status = 0
    begin
      if @PreCaseNum <> @CaseNum
        begin
          --插入主表
          IF @PreCaseNum <> ''
            BEGIN
              INSERT INTO StkoutBck (CLS, NUM, SETTLENO, SRC, RECCNT, TAX, TOTAL,
                        BILLTO, OCRDATE, FILDATE, STAT, NOTE, GENCLS, GENNUM, CLIENT,
                        PRECHKDATE)
              SELECT @Cls CLS, @Num NUM, @SettleNo SETTLENO, SRC, RECCNT, 0, 0,
                        CHKSTOREGID, GETDATE() OCRDATE, GETDATE() FILDATE, 7 STAT,
                        '由配货退货申请单['+@piCur_Num+']导入。箱号：' + @PreCaseNum + '。' + NOTE, '配货退货申请单', @piCur_Num, SRC,
                        GETDATE()
              FROM BCKDMD
              WHERE NUM = @piCur_Num

              --合计 StkoutBck 表中TOTAL,TAX
              SELECT @Total = sum(total), @Tax = sum(tax)
              FROM StkoutBckdtl
              WHERE num = @Num AND CLS = @CLS

              --更新 StkoutBck 中的TOTAL, TAX, WRH
              UPDATE StkoutBck
                SET total = @Total, tax = @Tax, WRH = @AlcWrh
                WHERE num = @Num and cls = @Cls

              --更新 StkoutBck 中的 FILLER, PRECHECKER
              UPDATE StkoutBck
              SET FILLER = @FILLER, PRECHECKER = @FILLER
              WHERE  num = @Num and cls = @Cls

              SET @poMSG = '自动生成单号为'+@Num+'的配货出货退货单'

              --回写 bckdmd
              UPDATE bckdmd
              SET locknum = @Num, lockcls = '配出退'
              WHERE num = @piCur_Num

              --取下一单号
              SELECT @Num = RIGHT( Max(Num)+10000000001,10) FROM StkoutBck WHERE Cls = @Cls
              IF @Num IS NULL  SET @Num = '0000000001'

              --行号清零
              set @line = 0
            END
        end
      set @PreCaseNum = @CaseNum
      --插入明细
      set @line = @line + 1
      INSERT INTO StkoutBckDtl (
        CLS, NUM, LINE, GDGID, SETTLENO, QTY,
        WSPRC, PRICE, TOTAL, TAX, INPRC, RTLPRC, CASES)
      VALUES (@Cls, @Num, @LINE, @GDGID, @SettleNo, @Qty,
        0, 0, 0, 0, 0, 0, @Cases)

     -- 更新 StkoutBckDtl 中的inprc,rtlprc,wrh
      UPDATE StkoutBckdtl
        SET inprc = b.inprc, rtlprc = b.rtlprc, wrh = b.wrh, wsprc = b.WHSPRC
        FROM StkoutBckdtl a, goods b
        WHERE a.gdgid = b.gid and a.num = @Num and Cls = @Cls
      IF @AutoGenBckBill_UseSameDtlWrh = 1
        UPDATE StkoutBckDTL SET WRH = @ALCWRH WHERE NUM = @NUM AND CLS = @CLS
      -- 更新 StkoutBckDtl 中的price
      EXEC(' UPDATE StkoutBckdtl SET price = b.'
        + @PriceType + ' FROM StkoutBckdtl a, goods b WHERE a.gdgid = b.gid AND A.CLS = '''+@CLS+''' AND a.num ='''+@Num+''' ')
      --是否去税
      SELECT @InPrcTax = inprctax FROM [system]
      IF @InPrcTax = 1
      BEGIN
        -- 更新 StkoutBckDtl 中的total
        UPDATE StkoutBckdtl
        SET total = price * qty
        WHERE num = @Num AND CLS = @CLS
        --更新 StkoutBckDtl 中的tax
        UPDATE StkoutBckdtl
        SET tax = a.total - round(a.total/(1+ (b.taxrate/100)), 4)
        FROM StkoutBckdtl a, goods b
        WHERE a.gdgid = b.gid and a.num = @Num AND A.CLS = @CLS
      END ELSE
      BEGIN
        --更新 StkoutBckDtl 中的tax
        UPDATE StkoutBckdtl
        SET tax = round(qty*(
          a.price - a.price /(1+ (gd.taxrate/100))
          ),4)
        FROM goods gd(nolock) , StkoutBckdtl a
        WHERE gd.gid = a.gdgid AND a.num = @Num AND A.CLS = @CLS
        -- 更新 StkoutBckDtl 中的total
        UPDATE StkoutBckdtl
        SET total =round(price /(1+ (taxrate/100)) * qty, 4)
        FROM StkoutBckdtl a, goods b
        WHERE a.gdgid = b.gid AND a.num = @Num AND A.CLS = @CLS
        --去税则重算price
        UPDATE StkoutBckdtl
        SET price = round(price /(1+ (taxrate/100)), 4)
        FROM StkoutBckdtl a, goods b
        WHERE a.gdgid = b.gid AND a.num = @Num AND A.CLS = @CLS
      END
      fetch next from c_BckDmdDtlDtl into
        @CaseNum, @gdgid, @Cases, @Qty  --, @Line
    end

    IF @PreCaseNum <> ''
            BEGIN
              INSERT INTO StkoutBck (CLS, NUM, SETTLENO, SRC, RECCNT, TAX, TOTAL,
                        BILLTO, OCRDATE, FILDATE, STAT, NOTE, GENCLS, GENNUM, CLIENT,
                        PRECHKDATE)
              SELECT @Cls CLS, @Num NUM, @SettleNo SETTLENO, SRC, RECCNT, 0, 0,
                        CHKSTOREGID, GETDATE() OCRDATE, GETDATE() FILDATE, 7 STAT,
                        '由配货退货申请单['+@piCur_Num+']导入。箱号：' + @PreCaseNum + '。' + NOTE, '配货退货申请单', @piCur_Num, SRC,
                        GETDATE()
              FROM BCKDMD
              WHERE NUM = @piCur_Num

              --合计 StkoutBck 表中TOTAL,TAX
              SELECT @Total = sum(total), @Tax = sum(tax)
              FROM StkoutBckdtl
              WHERE num = @Num AND CLS = @CLS

              --更新 StkoutBck 中的TOTAL, TAX, WRH
              UPDATE StkoutBck
                SET total = @Total, tax = @Tax, WRH = @AlcWrh
                WHERE num = @Num and cls = @Cls

              --更新 StkoutBck 中的 FILLER,PRECHECKER
              UPDATE StkoutBck
              SET FILLER = @FILLER, PRECHECKER = @FILLER
              WHERE  num = @Num and cls = @Cls

              SET @poMSG = '自动生成单号为'+@Num+'的配货出货退货单'

              --回写 bckdmd
              UPDATE bckdmd
              SET locknum = @Num, lockcls = '配出退'
              WHERE num = @piCur_Num
            END
  close c_BckDmdDtlDtl
  deallocate c_BckDmdDtlDtl

  EXEC BCKDMDCHK @piCur_Num, @FILLERCODE, '', 300, @poMSG OUTPUT
  return 0
END
GO
