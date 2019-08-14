SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RCVONEPOLYPAYRATEPRM]  
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
    @STORE INT,  
    @NUM VARCHAR(14),  
    @RCV INT,  
    @FOUND CHAR(1),  
    @cur_settleno int,  
    @STAT INT,  
    @NSTAT INT  
  
    SET @RET = 0  
    select @cur_settleno = max(no) from monthsettle  
    SELECT @STORE = USERGID FROM FASYSTEM(NOLOCK)  
    SELECT @NUM = NUM, @RCV = RCV, @NSTAT = STAT  
      FROM NPOLYPAYRATEPRM(NOLOCK) WHERE SRC = @SRC AND ID = @ID  
    IF @RCV <> @STORE  
    BEGIN  
     IF @CLS = '批量联销率'  
        SET @MSG = '收到接收单位非本单位的' + @CLS + '单；单号=' + @NUM  
      ELSE IF @CLS = '商品折扣'  
        SET @MSG = '收到接收单位非本单位的 商品折扣联销率协议 : 单号=' + @NUM  
      EXEC NPOLYPAYRATEPRM_REMOVE @SRC, @ID  
  
      RETURN 0  
    END  
  
    SELECT @STAT = STAT FROM POLYPAYRATEPRM(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS  
    IF @@ROWCOUNT = 1  
      SET @FOUND = '1'  
    ELSE  
      SET @FOUND = '0'  
  
    IF @FOUND = '1' AND @STAT = 800 AND @NSTAT = 1400 --唯一正确可处理状态  
    BEGIN  
      EXEC @RET = POLYPAYRATEPRM_ABORT @CLS = @CLS, @NUM = @NUM, @OPER = '网络交换', @TOSTAT = 1400, @MSG = @MSG output  
      IF @RET <> 0  
      BEGIN  
        UPDATE NPOLYPAYRATEPRM SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID  
        RETURN @RET  
      END  
      EXEC NPOLYPAYRATEPRM_REMOVE @SRC, @ID  
  
      RETURN 0  
    END  
  
    IF @FOUND = '1' OR (@FOUND = '0' AND @NSTAT = 1400)  
    BEGIN  
      EXEC NPOLYPAYRATEPRM_REMOVE @SRC, @ID  
      RETURN 0  
    END  
  
    --插入到当前表中  
    insert into POLYPAYRATEPRM (NUM, CLS, STAT, FILDATE, FILLER, CHKDATE, CHECKER, SNDTIME, PRNTIME,  
            LSTUPDTIME, LSTUPDOPER, NOTE, SETTLENO, RECCNT, TOPIC, PSETTLENO)  
    select NUM, CLS, 0, FILDATE, FILLER, CHKDATE, CHECKER, SNDTIME, PRNTIME,  
           LSTUPDTIME, LSTUPDOPER, NOTE, @cur_settleno, RECCNT, TOPIC, PSETTLENO  
    from NPOLYPAYRATEPRM(NOLOCK)  
    where SRC = @SRC AND ID = @ID  
  
    if @cls = '批量联销率'  
      insert into POLYPAYRATEPRMDTL(NUM, CLS, LINE, DEPT, VENDOR, BRAND, POLYPAYRATE, ASTART, AFINISH, NOTE)  
      select N.NUM, N.CLS, N.LINE, N.DEPT, N.VENDOR, N.BRAND, N.POLYPAYRATE, N.ASTART, N.AFINISH, N.NOTE  
      from NPOLYPAYRATEPRMDTL N(NOLOCK)  
        where SRC = @SRC AND ID = @ID  
    else if @cls = '商品折扣'  
      insert into POLYPAYRATEPRMDTL(NUM, CLS, LINE, DEPT, VENDOR, BRAND, POLYPAYRATE, STARTDIS, FINISHDIS, ASTART, AFINISH, NOTE)  
      select N.NUM, N.CLS, N.LINE, N.DEPT, N.VENDOR, N.BRAND, N.POLYPAYRATE, N.STARTDIS, N.FINISHDIS, N.ASTART, N.AFINISH, N.NOTE  
      from NPOLYPAYRATEPRMDTL N(NOLOCK)  
        where SRC = @SRC AND ID = @ID  
  
    --门店接收时自动增加生效门店记录  
    INSERT INTO POLYPAYRATEPRMLACSTORE(NUM, CLS, STOREGID)  
    SELECT NUM, CLS, @STORE FROM NPOLYPAYRATEPRM(NOLOCK)  
    WHERE SRC = @SRC AND ID = @ID  
  
    EXEC @RET = POLYPAYRATEPRM_CHECK @NUM, @CLS, '网络交换', 800, @MSG output  
    IF @RET <> 0  
    BEGIN  
      UPDATE NPOLYPAYRATEPRM SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID  
      RETURN @RET  
    END  
    EXEC NPOLYPAYRATEPRM_REMOVE @SRC, @ID  
    RETURN 0  
END  
GO