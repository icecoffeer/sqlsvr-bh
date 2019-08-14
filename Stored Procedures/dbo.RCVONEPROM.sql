SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RCVONEPROM]  
(  
  @SRC      INT,  
  @ID       INT,  
  @CLS      VARCHAR(10),  
  @OPER     VARCHAR(30),  
  @MSG      VARCHAR(255) OUTPUT  
)  
AS  
BEGIN  
  DECLARE  
    @RET INT,  
    @FLAG INT,  
    @STORE INT,  
    @NUM VARCHAR(14),  
    @RCV INT,  
    @FOUND CHAR(1),  
    @cur_settleno int,  
    @STAT INT,  
    @NSTAT INT  
  
  select @cur_settleno = max(no) from monthsettle  
  SET @RET = 0  
  SELECT @STORE = USERGID FROM FASYSTEM(NOLOCK)  
  SELECT @NUM = NUM, @RCV = RCV, @NSTAT = STAT  
  FROM NPROM(NOLOCK) WHERE SRC = @SRC AND ID = @ID  
  IF @RCV <> @STORE  
  BEGIN  
    SET @MSG = '收到接收单位非本单位的' + @CLS + '促销单；单号=' + @NUM  
    EXEC DELNPROM @SRC, @ID  
    RETURN 0  
  END  
  
  EXEC @RET = RCVCHKPROM @SRC, @ID, @CLS, @OPER, @MSG output  
  IF @RET <> 0  
  BEGIN  
    SET @MSG = '接收' + @CLS + '促销单' + @NUM + '失败。' + '单据存在不合法记录:' + @MSG;  
    UPDATE NPROM SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID  
    RETURN @RET  
  END  
  
  --接收促销主题  
  exec PRCPRMTOPICRCV @SRC, @ID;  
  
  SELECT @FLAG = 1, @STAT = STAT FROM PROM(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS  
  IF @@ROWCOUNT = 1  
    SET @FOUND = '1'  
  ELSE  
    SET @FOUND = '0'  
  
  IF @FOUND = '1' AND ((@STAT = 100 AND @NSTAT = 110) --唯一正确可处理状态  
       OR (@STAT = 800 AND @NSTAT = 1400)) --判断已生效、已终止状态 add by qzh CSTPRO-1110  
  BEGIN  
    if @STAT = 100 AND @NSTAT = 110
      EXEC @RET = PROMDLT @CLS, @NUM, '网络交换', 110, @MSG output
    else if @STAT = 800 AND @NSTAT = 1400
      EXEC @RET = PROMDLT_OCR @CLS, @NUM, '网络交换', 1400, @MSG output          
    IF @RET <> 0  
    BEGIN  
      UPDATE NPROM SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID  
      RETURN @RET  
    END  
    EXEC DELNPROM @SRC, @ID  
    RETURN 0  
  END  
  
  IF @FOUND = '1' OR (@FOUND = '0' AND @NSTAT = 110)  
       OR (@FOUND = '0' AND @NSTAT = 1400) --判断已终止状态 add by qzh CSTPRO-1110  
  BEGIN  
    EXEC DELNPROM @SRC, @ID  
    RETURN 0  
  END  
  
  --插入到当前表中  
  insert into PROM (NUM, CLS, STAT, FILDATE, FILLER, SNDTIME, PRNTIME,  
    LSTUPDTIME, TOPIC, STORESCOPE, NOTE, ASTART, AFINISH,  
    CYCLE, CSTART, CFINISH, CSPEC, PSETTLENO, OCRTIME, FIXRATIO, GFTRATIO,  
    HASCOND, EXPROM, MONTHSETTLENO, DLTPRICEPROM, OVERWRITERULE, PRIORITY)  
  select NUM, CLS, 0, FILDATE, FILLER, SNDTIME, PRNTIME,  
    LSTUPDTIME, TOPIC, STORESCOPE, NOTE, ASTART, AFINISH,  
    CYCLE, CSTART, CFINISH, CSPEC, PSETTLENO, OCRTIME, FIXRATIO, GFTRATIO,  
    HASCOND, EXPROM, @cur_settleno, DLTPRICEPROM, OVERWRITERULE, PRIORITY  
  from NPROM(NOLOCK)  
  where SRC = @SRC AND ID = @ID  
  
  insert into PROMGOODS (NUM, CLS, LINE, GDGID, GDCODE, QPC, QPCSTR, RTLPRC, MBRPRC,  
    CNTRINPRC, COST, PRMDIV1, PRMDIV2, PRMDIV3, QTY, FLAG, ISDLT, PREC, ROUNDTYPE)  
  select N.NUM, N.CLS, N.LINE, G.LGID, N.GDCODE, N.QPC, N.QPCSTR, N.RTLPRC, N.MBRPRC,  
    N.CNTRINPRC, N.COST, N.PRMDIV1, N.PRMDIV2, N.PRMDIV3, N.QTY, N.FLAG, N.ISDLT, N.PREC, N.ROUNDTYPE  
  from NPROMGOODS N(NOLOCK), GDXLATE G(NOLOCK)  
  where G.NGID = N.GDGID  
    and SRC = @SRC AND ID = @ID  
--ShenMin, 插入GDGID为-1（这些数据记录的是客单价、客单量促销中的类别等）的数据  
  insert into PROMGOODS (NUM, CLS, LINE, GDGID, GDCODE, QPC, QPCSTR, RTLPRC, MBRPRC,  
    CNTRINPRC, COST, PRMDIV1, PRMDIV2, PRMDIV3, QTY, FLAG, ISDLT, PREC, ROUNDTYPE)  
  select NUM, CLS, LINE, GDGID, GDCODE, QPC, QPCSTR, RTLPRC, MBRPRC,  
    CNTRINPRC, COST, PRMDIV1, PRMDIV2, PRMDIV3, QTY, FLAG, ISDLT, PREC, ROUNDTYPE  
  from NPROMGOODS(NOLOCK)  
  where SRC = @SRC AND ID = @ID  
    and GDGID = -1;  
  
  --门店接收时自动增加生效门店记录  
  INSERT INTO PROMSTORE(NUM, CLS, STOREGID)  
  SELECT NUM, CLS, @STORE FROM NPROM(NOLOCK)  
  WHERE SRC = @SRC AND ID = @ID  
  
  INSERT INTO PROMQTY(NUM, CLS, PRMNO, QTY, PRMTOTAL, IFGFT, GFTQTY, PTOTAL)  
  SELECT NUM, CLS, PRMNO, QTY, PRMTOTAL, IFGFT, GFTQTY, PTOTAL  
  FROM NPROMQTY(NOLOCK)  
  WHERE SRC = @SRC AND ID = @ID  
  
  INSERT INTO PROMMONEY(NUM, CLS, PRMNO, TOTAL, PRMTOTAL, IFGFT, GFTQTY, PTOTAL, ISFULL)  
  SELECT NUM, CLS, PRMNO, TOTAL, PRMTOTAL, IFGFT, GFTQTY, PTOTAL, ISFULL  
  FROM NPROMMONEY(NOLOCK)  
  WHERE SRC = @SRC AND ID = @ID  
  
  INSERT INTO PROMGFT(NUM, CLS, PRMNO, LINE, GFTGID, GFTCODE, QPC, QPCSTR, RTLPRC, MBRPRC, CNTRINPRC, COST,  
    PRMDIV1, PRMDIV2, PRMDIV3, QTY, FLAG, ISDLT)  
  SELECT NUM, CLS, PRMNO, LINE, GFTGID, GFTCODE, QPC, QPCSTR, RTLPRC, MBRPRC, CNTRINPRC, COST,  
    PRMDIV1, PRMDIV2, PRMDIV3, QTY, FLAG, ISDLT  
  FROM NPROMGFT(NOLOCK)  
  WHERE SRC = @SRC AND ID = @ID  
  
  EXEC @RET = PROMCHK @NUM, @CLS, '网络交换', 100, @MSG output  
  IF @RET <> 0  
  BEGIN  
    UPDATE NPROM SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID  
    RETURN @RET  
  END  
  EXEC DELNPROM @SRC, @ID  
  
  RETURN 0  
END  

GO