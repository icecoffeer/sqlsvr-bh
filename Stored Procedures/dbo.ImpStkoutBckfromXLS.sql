SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ImpStkoutBckfromXLS]
(
  @VSPID INT,
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
    @Line int,
    @Cases money,           @Qty money,
    @gdgid int,
    @StoreGid int,          @PreStoreGid int,
    @PreSort char(13),      @Sort char(13)

  SET @Cls = '配货'
  SELECT @Num = RIGHT( Max(Num)+10000000001,10) FROM StkoutBck WHERE Cls = @Cls
  IF @Num IS NULL  SET @Num = '0000000001'
  SELECT @SettleNo =  MAX(No) FROM MonthSettle
    --根据 HDOPIOTN 取得PriceType
  EXEC OPTREADINT 43, 'pricetype', 0, @PriceType OUTPUT
  EXEC OPTREADINT 518, 'AutoGenBckBillGetWrhMethod', 0, @AutoGenBckBillGetWrhMethod OUTPUT
  EXEC OPTREADINT 518, 'AutoGenBckBill_UseSameDtlWrh', 0, @AutoGenBckBill_UseSameDtlWrh OUTPUT
  SELECT @AlcWrh = ALCWRH FROM [system]

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

  DECLARE
    @SRC int
  select @SRC = USERGID FROM SYSTEM

  --设置初始值
  set @PreStoreGid = 0
  set @line = 0
  set @PreSort = 0

  declare c_ImpFromXls cursor for
    select T.STOREGID, T.GDGID, T.GDQTY, substring(G.SORT, 1, 2) SORT
    from TMPIMPXLSSTKOUTBCK T(nolock), GOODS G(nolock)
    where SPID = @VSPID
      and T.GDGID *= G.GID
    ORDER BY STOREGID, SORT
  open c_ImpFromXls
  fetch next from c_ImpFromXls into
    @StoreGid, @gdgid, @Qty, @Sort

  while @@fetch_status = 0
    begin
      if (@PreStoreGid <> @StoreGid) or (@PreSort <> @Sort)
        begin
          --插入主表
          IF (@PreStoreGid <> '')
            BEGIN
              INSERT INTO StkoutBck (CLS, NUM, SETTLENO, SRC, RECCNT, TAX, TOTAL,
                        BILLTO, OCRDATE, FILDATE, STAT, NOTE, GENCLS, GENNUM, CLIENT,
                        PRECHKDATE)
              VALUES (@Cls, @Num, @SettleNo, @SRC, 0, 0, 0,
                        @PreStoreGid, GETDATE(), GETDATE(), 0,
                        '由EXCEL文件导入' , '', '', @PreStoreGid,
                        GETDATE())

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

              --取下一单号
              SELECT @Num = RIGHT( Max(Num)+10000000001,10) FROM StkoutBck WHERE Cls = @Cls
              IF @Num IS NULL  SET @Num = '0000000001'

              --行号清零
              set @line = 0
            END
        end
      set @PreStoreGid = @StoreGid
      set @PreSort = @Sort
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
      fetch next from c_ImpFromXls into
        @StoreGid, @gdgid, @Qty, @Sort
    end

    IF @PreStoreGid <> 0
            BEGIN
              INSERT INTO StkoutBck (CLS, NUM, SETTLENO, SRC, RECCNT, TAX, TOTAL,
                        BILLTO, OCRDATE, FILDATE, STAT, NOTE, GENCLS, GENNUM, CLIENT,
                        PRECHKDATE)
              VALUES (@Cls, @Num, @SettleNo, @SRC, 0, 0, 0,
                        @PreStoreGid, GETDATE(), GETDATE(), 0,
                        '由EXCEL文件导入' , '', '', @PreStoreGid,
                        GETDATE())

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
            END
  close c_ImpFromXls
  deallocate c_ImpFromXls
  delete from TMPIMPXLSSTKOUTBCK where SPID = @@SPID
  return 0
END
GO
