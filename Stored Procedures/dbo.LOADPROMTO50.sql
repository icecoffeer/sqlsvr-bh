SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LOADPROMTO50]
(
  @PICLS    VARCHAR(10),
  @PINUM    VARCHAR(14),
  @PIOPER   VARCHAR(30),
  @POERR_MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  declare
  @VRET     INT,
  @VASTART  DATETIME,
  @VAFINISH   DATETIME,
  @VCYCLE   DATETIME,
  @VCSTART  DATETIME,
  @VCFINISH DATETIME,
  @VCSPEC   VARCHAR(255),
  @VPSETTLENO     INT,
  @VFIXRATIO  DECIMAL(24,4),
  @VGFTRATIO  DECIMAL(24,4),
  @VHASCOND INT,
  @VQPC   DECIMAL(24,4),
  @VIQPCSTR  VARCHAR(20),
  @StoreGid       int,
  @line           int,
  @GdGid  int,
  @GdCode  char(13),
  @Flag  int,
  @PIGDGID  int,
  @PIGDCODE char(13),
  @IQPCSTR VARCHAR(20),
  @PRMNO int,
  @GFTGID int,
  @GFTCODE char(13),
  @QTY DECIMAL(24,4),
  @C_GftCode char(13),
  @vDltPriceProm smallint,  --是否取消价格促销
  @OVERWRITERULE INT, --赠券促销是否覆盖之前的规则
  @vNewLine Int

  declare SDTL cursor for
    SELECT STOREGID FROM PROMSTORE
      WHERE NUM = @PINUM and CLS = @PICLS

  declare CDTL cursor for
    SELECT FLAG,LINE,GDGID,GDCODE FROM PROMGOODS
      WHERE NUM = @PINUM AND CLS = @PICLS AND ISDLT = 0

  declare CGFT cursor for
    SELECT PRMNO,FLAG,LINE,GFTGID,GFTCODE,QTY FROM PROMGFT
      WHERE NUM = @PINUM AND CLS = @PICLS AND ISDLT = 0

  set @VRET = 0
  SELECT @VASTART=ASTART, @VAFINISH=AFINISH, @VCYCLE=CYCLE, @VCSTART=CSTART, @VCFINISH=CFINISH,
         @VCSPEC=CSPEC, @VPSETTLENO=PSETTLENO, @VFIXRATIO=FIXRATIO, @VGFTRATIO=GFTRATIO, @VHASCOND=HASCOND,
         @VDLTPRICEPROM = DLTPRICEPROM, @OVERWRITERULE = OVERWRITERULE
  FROM PROM WHERE NUM = @PINUM AND CLS = @PICLS

  INSERT INTO PROMOTEQTY(BILLNUM, CLS, PRMNO, QTY, PRMTOTAL, IFGFT, GFTQTY, PTOTAL)
  SELECT NUM, CLS, PRMNO, QTY, PRMTOTAL, IFGFT, GFTQTY, PTOTAL FROM PROMQTY
    WHERE NUM = @PINUM AND CLS = @PICLS

  --对写入PromoteMoney的数据按照Total从小到大进行排序,并更新PrmNo,使得其与Total顺序一致
  Set @vNewLine = 0
  IF OBJECT_ID('TEMPDB..#tmp_PrmMoney') IS NOT NULL DROP TABLE #tmp_PrmMoney
  SELECT NUM, CLS, PRMNO, TOTAL, PRMTOTAL, IFGFT, GFTQTY, ISFULL, PTOTAL
    Into #tmp_PrmMoney FROM PROMMONEY where 0=1 --创建表结构
  Declare Cprmm Cursor For
    SELECT PRMNO FROM PROMMONEY
      WHERE NUM = @PINUM AND CLS = @PICLS
    Order By Total
  open Cprmm
  fetch next from Cprmm into @PRMNO
  while @@fetch_status = 0
  begin
    Set @vNewLine = @vNewLine + 1
    insert into #tmp_PrmMoney(NUM, CLS, PRMNO, TOTAL, PRMTOTAL, IFGFT, GFTQTY, ISFULL, PTOTAL)
    SELECT NUM, CLS, @vNewLine, TOTAL, PRMTOTAL, IFGFT, GFTQTY, ISFULL, PTOTAL FROM PromMoney
      WHERE NUM = @PINUM AND CLS = @PICLS And PRMNO = @PRMNO

    fetch next from Cprmm into @PRMNO
  end
  CLOSE Cprmm
  DEALLOCATE Cprmm
  --将排序后的数据写进生效表
  INSERT INTO PROMOTEMONEY(BILLNUM, CLS, PRMNO, TOTAL, PRMTOTAL, IFGFT, GFTQTY, ISFULL, PTOTAL)
  SELECT NUM, CLS, PRMNO, TOTAL, PRMTOTAL, IFGFT, GFTQTY, ISFULL, PTOTAL FROM #tmp_PrmMoney
    WHERE NUM = @PINUM AND CLS = @PICLS

  open CGFT
  fetch next from CGFT into @PRMNO, @FLAG, @LINE, @GFTGID, @GFTCODE, @QTY
  while @@fetch_status = 0
  begin
    SELECT @VQPC = QPC, @VIQPCSTR = QPCSTR
    FROM GDINPUT(nolock)
    WHERE GID = @GFTGID AND CODE = @GFTCODE

    INSERT INTO PROMOTEGFT(BILLNUM, CLS, PRMNO, BILLLINE, GFTGID, GFTCODE, QTY, FLAG, GFTQPC)
    VALUES(@PINUM, @PICLS, @PRMNO, @LINE, @GFTGID, @GFTCODE, @QTY, @FLAG, @VQPC)

    SET @PIGDGID = @GFTGID
    SET @PIGDCODE = @GFTCODE
    SET @IQPCSTR = @VIQPCSTR
    declare CGFTCODE CURSOR for
      SELECT CODE FROM GDINPUT
      WHERE GID = @GFTGID AND CODE <> @GFTCODE
        AND QPCSTR = @VIQPCSTR

    OPEN CGFTCODE
    fetch next from CGFTCODE into @C_GftCode
    while @@fetch_status = 0
    begin
      INSERT INTO PROMOTEGFT(BILLNUM, CLS, PRMNO, BILLLINE, GFTGID, GFTCODE, QTY, FLAG, GFTQPC)
      SELECT NUM, CLS, PRMNO, LINE, GFTGID, @C_GftCode, QTY, FLAG, @VQPC
        FROM PROMGFT
      WHERE NUM = @PINUM AND CLS = @PICLS AND PRMNO = @PRMNO AND FLAG = @FLAG AND LINE = @LINE

      fetch next from CGFTCODE into @C_GftCode
    end
    close CGFTCODE
    DEALLOCATE CGFTCODE
    fetch next from CGFT into @PRMNO, @FLAG, @LINE, @GFTGID, @GFTCODE, @QTY
  end
  close CGFT
  --
  DEALLOCATE CGFT
  IF rtrim(@PICLS) = '赠券'
  BEGIN
    INSERT INTO PROMOTEGFT(BILLNUM, CLS, PRMNO, BILLLINE, GFTGID, GFTCODE, QTY, FLAG, GFTQPC)
      SELECT NUM, CLS, PRMNO, 1, convert(int, convert(decimal(24, 0), PTOTAL)), convert(char(13), PTOTAL), 1, 1, 1 FROM PROMMONEY
        WHERE NUM = @PINUM AND CLS = @PICLS
  END

  --以金额促销级别中赠品数量更新PROMOTEGFT表，确保数据一致性
  SELECT @VRET = COUNT(*) FROM PROMOTEMONEY WHERE BILLNUM = @PINUM AND CLS = @PICLS
  IF @VRET > 0
  begin
    UPDATE PromoteGft
      SET Qty = p.GftQty
    FROM PromoteMoney AS p
    WHERE PromoteGft.BillNum = p.BillNum AND PromoteGft.Cls = p.Cls AND PromoteGft.PrmNo = p.PrmNo
      AND p.BillNum = @PINUM AND p.Cls = @PICLS
   end

  --以数量促销级别中赠品数量更新PROMOTEGFT表，确保数据一致性
  SELECT @VRET = COUNT(*) FROM PROMOTEQTY WHERE BILLNUM = @PINUM AND CLS = @PICLS
  IF @VRET > 0
  begin
    UPDATE PromoteGft
      SET Qty = p.GftQty
    FROM PromoteQty AS p
      WHERE PromoteGft.BillNum = p.BillNum AND PromoteGft.Cls = p.Cls AND PromoteGft.PrmNo = p.PrmNo AND p.BillNum = @PINUM AND p.Cls = @PICLS
  end
  --
  IF @OVERWRITERULE = 1 /*zhujie 2009.08.31 后单压前单*/
    DELETE FROM PROMOTE WHERE CLS = @PICLS
  open CDTL
  fetch next from CDTL into @flag, @line, @gdgid, @gdcode
  while @@fetch_status = 0
  begin
    set @VRET = 0
    open SDTL
    fetch next from SDTL into @StoreGid
    while @@fetch_status = 0
    begin
      EXEC @VRET = LOADPROMDTLTO50 @PICLS, @PINUM, @StoreGid, @VPSETTLENO,
                   @VASTART,@VAFINISH,@VCYCLE,@VCSTART,@VCFINISH, @VCSPEC, @flag,
                   @line, @gdgid, @gdcode, @VFIXRATIO, @VGFTRATIO, @VHASCOND, @POERR_MSG
      IF @VRET <> 0 RETURN(@VRET)

      ---取消原价格促销
      if @vDltPriceProm = 1
      begin
        exec @vRet = DLTONEGOODSPRCPROM @GDGid, @StoreGid, @vAStart, @vAFinish, @poErr_Msg
        if @vRet <> 0
          return(@vRet)
      end
      fetch next from SDTL into @StoreGid
    end
    close SDTL

    fetch next from CDTL into @flag, @line, @gdgid, @gdcode
  end
  CLOSE CDTL
  DEALLOCATE CDTL
  DEALLOCATE SDTL

  RETURN(@VRET)
END
GO
