SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ALCBYSTORERCV]
(
  @src_gid int,
	@id int,
	@new_oper int
)
AS
BEGIN
  declare
  @usergid int,
  @zbgid int,
  @new_gdgid int,
  @NET_NUM CHAR(14),
  @NEW_NUM CHAR(14),
  @Max_Num varchar(10),
  @SRCNUM VARCHAR(10),
  @RCV_GID INT,
  @NET_STAT SMALLINT,
  @NET_TYPE SMALLINT,
  @CHECKER INT,
  @n_filler int,
  @cnt int,
  @Line int,
  @RET INT,
  @settleno SMALLINT,
  @MSG VARCHAR(255)

  SELECT @RCV_GID = RCV, @NET_STAT = STAT, @NET_TYPE = TYPE, @CHECKER = CHECKER, @n_filler = filler, @NET_NUM = NUM
  FROM NAlcByStore(NOLOCK) WHERE ID = @id AND SRC = @SRC_GID

  IF @@ROWCOUNT = 0 OR @NET_NUM IS NULL
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不存在'
    RETURN 1
  END

  IF EXISTS(SELECT 1 FROM AlcByStore(NOLOCK) WHERE SRCNUM = @NET_NUM)
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '已经被接收'
    RETURN 2
  END

  IF (SELECT MAX(USERGID) FROM SYSTEM(NOLOCK)) <>  @RCV_GID
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '接收单位不是本单位'
    RETURN 3
  END

  IF @NET_TYPE <> 1
  BEGIN
  	SET @MSG = '[接收]单据' +  @NET_NUM + '不在接收缓冲区中'
  	RETURN 4
    END

  select @n_filler = LGid from EMPXLATE where NGid = @n_filler
  if @@RowCount < 1
  begin
      raiserror('本地未包含填单人资料', 16, 1)
      return(5)
  end

  select @CHECKER = LGid from EMPXLATE where NGid = @CHECKER
  if @@RowCount < 1
  begin
      raiserror('本地未包含审核人资料', 16, 1)
      return(8)
  end

  select @cnt = sum(case when X.LGid is null then 1 else 0 end)
      from NAlcByStoredtl N, GDXLATE X
      where N.Src = @src_gid and N.Id = @id and N.GdGid *= X.NGid
  if @cnt > 0
  begin
      raiserror('本地未包含商品资料', 16, 1)
      return(9)
  end

  select @usergid = usergid, @zbgid = zbgid
  from system
  if @usergid <> @zbgid
  begin
    select @Max_Num = max(Num) from AlcByStore
    if @Max_Num IS NULL
      SELECT @NEW_NUM = '0000000001'
    else
      execute NEXTBN @ABN = @Max_Num, @NEWBN = @NEW_NUM output

    select @settleno = isnull(max(no), 0)
    from monthsettle(NOLOCK)

    INSERT INTO AlcByStore(NUM, SETTLENO, STAT, FILLER, FILDATE, CHECKER, DMDDATE, TOTAL,
      TAX, QTY, NOTE, CLS, DESRCTYPE, SRCNUM, DESRCNUM)
  	SELECT @NEW_NUM, @settleno, STAT, @n_filler, FILDATE, @CHECKER, DMDDATE, TOTAL,
      TAX, QTY, NOTE, CLS, DESRCTYPE, @NET_NUM, DESRCNUM
  	FROM NALCBYSTORE(NOLOCK)
  	WHERE SRC = @SRC_GID AND ID = @id

    IF @@ERROR <> 0
  	BEGIN
      SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
      RETURN 6
  	END

    insert into AlcByStoreDtl2(NUM, STOREGID)
		values (@NEW_NUM, @SRC_GID)

  	IF @@ERROR <> 0
  	BEGIN
      SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
      RETURN 7
  	END

    declare C_AlcByStore cursor for
	  select X.LGid, N.Line from NAlcByStoredtl N, GDXLATE X
      where N.Src = @src_gid and N.Id = @id and X.NGid = N.GdGid
	  open C_AlcByStore
	  fetch next from C_AlcByStore into @new_gdgid, @Line
	  while @@fetch_status = 0
	  begin
  	  INSERT INTO ALCBYSTOREDTL(NUM, LINE, GDGID, CASES, QTY, INVQTY, TOTAL, TAX, ASNQTY)
  	  SELECT @NEW_NUM, LINE, @new_gdgid, CASES, QTY, INVQTY, TOTAL, TAX, ASNQTY
  	  FROM NALCBYSTOREDTL(NOLOCK)
  	  WHERE SRC = @SRC_GID AND ID = @id AND LINE = @Line

  	  IF @@ERROR <> 0
  	  BEGIN
        SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
        RETURN 7
  	  END

  	  fetch next from C_AlcByStore into @new_gdgid, @Line
  	END
  	close C_AlcByStore
    deallocate C_AlcByStore

  	DELETE FROM NALCBYSTORE WHERE ID = @id AND SRC = @SRC_GID
  	DELETE FROM NALCBYSTOREDTL WHERE ID = @id AND SRC = @SRC_GID

  	SET @MSG = '单据：' + @NET_NUM + '接收成功' + @MSG

  	RETURN 0
	END else
  begin
   declare
   @QTY int,
   @CASES money,
   @TOTAL money,
   @TAX money

    SELECT @SRCNUM = SRCNUM
    FROM NAlcByStore(NOLOCK) WHERE ID = @id AND SRC = @SRC_GID

    IF NOT EXISTS(SELECT 1 FROM ALCBYSTORE(NOLOCK) WHERE NUM = @SRCNUM )
    BEGIN
      SET @MSG = '原单据' + @SRCNUM +'不存在或已被删除'
      return(10)
    END

  	SELECT @QTY = QTY, @TAX = TAX, @TOTAL = TOTAL
  	FROM NAlcByStore(NOLOCK) WHERE ID = @id AND SRC = @SRC_GID

  	UPDATE AlcByStore SET QTY = @QTY, TOTAL = @TOTAL, TAX = @TAX, SRCNUM = @NET_NUM
  	WHERE NUM = @SRCNUM

  	IF @@ERROR <> 0
  	BEGIN
    	SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
    	RETURN 6
  	END

  	declare C_AlcByStore2 cursor for
  	select LINE from NAlcByStoredtl
      where SRC = @src_gid and ID = @id
	  open C_AlcByStore2
	  fetch next from C_AlcByStore2 into @Line
	  while @@fetch_status = 0
	  BEGIN
  	  SELECT @CASES = CASES, @QTY = QTY, @TOTAL = TOTAL, @TAX = TAX
  	  FROM NALCBYSTOREDTL(NOLOCK) WHERE ID = @id AND SRC = @SRC_GID AND LINE = @Line

    	UPDATE ALCBYSTOREDTL SET CASES = @CASES, QTY = @QTY, TOTAL = @TOTAL, TAX = @TAX
    	WHERE Num = @SRCNUM AND LINE = @Line

  	  IF @@ERROR <> 0
    	BEGIN
       	SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
    	  RETURN 7
  	  END
  	  fetch next from C_AlcByStore2 into @Line
  	END
  	close C_AlcByStore2
    deallocate C_AlcByStore2

  	DELETE FROM NALCBYSTORE WHERE ID = @id AND SRC = @SRC_GID
  	DELETE FROM NALCBYSTOREDTL WHERE ID = @id AND SRC = @SRC_GID

  	IF @NET_STAT = 1
  	BEGIN
    	EXEC @RET = AlcByStoreCheck @SRCNUM, @CHECKER
    	IF @RET <> 0 RETURN @RET
  	END

  	SET @MSG = '单据：' + @NET_NUM + '接收成功' + @MSG

  	RETURN 0
	end
END
GO
