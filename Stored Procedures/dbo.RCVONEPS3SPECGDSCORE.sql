SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RCVONEPS3SPECGDSCORE]
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

    select @cur_settleno = max(no) from monthsettle
    SET @RET = 0
    SELECT @STORE = USERGID FROM FASYSTEM(NOLOCK)
    SELECT @NUM = NUM, @RCV = RCV, @NSTAT = STAT
    FROM NPS3SPECGDSCORE(NOLOCK) WHERE SRC = @SRC AND ID = @ID
    IF @RCV <> @STORE
    BEGIN
      SET @MSG = '收到接收单位非本单位的' + @CLS + '单；单号=' + @NUM
      EXEC NPS3SPECGDSCORE_REMOVE @SRC, @ID
      RETURN 0
    END

    SELECT @STAT = STAT FROM PS3SPECGDSCORE(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS
    IF @@ROWCOUNT = 1
      SET @FOUND = '1'
    ELSE
      SET @FOUND = '0'

    IF @FOUND = '1'
    BEGIN
      EXEC NPS3SPECGDSCORE_REMOVE @SRC, @ID
      RETURN 0
    END

    --插入到当前表中
    insert into PS3SPECGDSCORE (NUM, CLS, STAT, FILDATE, FILLER, SNDTIME, PRNTIME, CHKDATE, CHECKER, 
            LSTUPDTIME, LSTUPDOPER, NOTE, SETTLENO, RECCNT)
    select NUM, CLS, 0, FILDATE, FILLER, SNDTIME, PRNTIME, CHKDATE, CHECKER, 
           LSTUPDTIME, LSTUPDOPER, NOTE, @cur_settleno, RECCNT
    from NPS3SPECGDSCORE(NOLOCK)
    where SRC = @SRC AND ID = @ID

    insert into PS3SPECGDSCOREDTL(NUM, CLS, LINE, GDGID, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE, MAXDISCOUNT, BEGINDATE, ENDDATE, NOTE)
    select N.NUM, N.CLS, N.LINE, N.GDGID, N.MINAMOUNT, N.AMOUNT, N.SCORESORT, N.SCORE, N.NSCORE, N.MAXDISCOUNT, N.BEGINDATE, N.ENDDATE, N.NOTE
    from NPS3SPECGDSCOREDTL N(NOLOCK)
    where SRC = @SRC AND ID = @ID
    
    insert into PS3SPECGDSCOREPROMSUBJOUTDTL(NUM, CLS, LINE, SUBJCODE, SUBJCLS)
    select NUM, CLS, LINE, SUBJCODE, SUBJCLS
    from NPS3SPECGDSCOREPROMSUBJOUTDTL(NOLOCK)
    where SRC = @SRC AND ID = @ID

    --门店接收时自动增加生效门店记录
    INSERT INTO PS3SPECGDSCORELACSTORE(NUM, CLS, STOREGID)
    SELECT NUM, CLS, @STORE FROM NPS3SPECGDSCORE(NOLOCK)
    WHERE SRC = @SRC AND ID = @ID

    EXEC @RET = PS3SPECGDSCORE_CHECK @NUM, @CLS, '网络交换', 100, @MSG output
    IF @RET <> 0
    BEGIN
      UPDATE NPS3SPECGDSCORE SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID
      RETURN @RET
    END
    EXEC NPS3SPECGDSCORE_REMOVE @SRC, @ID
    RETURN 0
END
GO
