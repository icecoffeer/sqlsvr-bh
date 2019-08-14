SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[BillToAdjRcv_FeedBck]
(
  @Src int,                 --来源单位
  @ID int,                  --网络ID
  @Oper Char(30),           --操作人
  @Msg VARCHAR  (255) OUTPUT  --出错信息
) as
begin
  declare
    @n_Num Char(14),
    @n_Stat SMALLINT,
    @v_SETTLENO INT,
    @v_Cnt INT,
    @v_RcvGid INT,
    @v_UserGid INT,
    @v_Ret Int,
    @v_BckStat INT

  Select @n_Num = NUM, @n_Stat = STAT, @v_RcvGid = RCV
    from NBILLTOADJ(nolock) where SRC = @Src and ID = @ID

  Select @v_UserGid = UserGid from FASYSTEM(nolock)
  IF @v_UserGid <>  @v_RcvGid
  BEGIN
    SET @MSG = '[接收]单据' +  @n_Num + '接收单位不是本单位'
    RETURN 1
  END

  --门店不允许重复接收
  IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID <> ZBGID)
    and EXISTS(SELECT 1 FROM BILLTOADJ(NOLOCK) WHERE NUM = @n_Num)
  begin
    SET @Msg = '该单据已被接收过,不允许重复接收'
    UPDATE NBILLTOADJ set NSTAT = 1, NNOTE = @Msg where SRC = @Src and ID = @ID

    RETURN 1
  end

  /*在接收单据时验证网络单据的完整性， */
  if not exists (select 1 from NBILLTOADJ(NOLOCK) WHERE SRC = @SRC AND ID = @ID AND NUM = @n_Num) or
     not exists (select 1 from NBILLTOADJFEEDBCKDTL(NOLOCK) WHERE SRC = @SRC AND ID = @ID AND NUM = @n_Num)
   BEGIN
    SET @MSG = '[接收]单据' + @n_Num + '的明细内容发送时丢失'
    RETURN 1
  END

  SELECT @v_Cnt = SUM(CASE when X.LGid is null then 1 else 0 end)
  from NBILLTOADJDTL N, GDXLATE X
    where N.Id = @ID and N.GdGid *= X.NGid
  if @v_Cnt > 0
  begin
    set @Msg = '本地未包含商品资料'
    update NBILLTOADJ set NSTAT = 1,NNOTE = @Msg where SRC = @Src and ID = @ID
    return 1
  end

  SELECT @v_SETTLENO = MAX(NO) FROM MONTHSETTLE(NOLOCK)
  --门店接收
  IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID <> ZBGID)
  BEGIN
    --第一次接收
    IF NOT EXISTS(SELECT 1 FROM BILLTOADJ(NOLOCK) WHERE NUM = @n_Num)
    BEGIN
      DELETE FROM BILLTOADJDTL WHERE NUM = @n_Num
      DELETE FROM BILLTOADJFEEDBCKDTL WHERE NUM = @n_Num
      DELETE FROM BILLTOADJLACDTL WHERE NUM = @n_Num

      INSERT INTO BILLTOADJ(NUM, SETTLENO, SRC, FILLER, FILDATE, CHECKER, CHKDATE, RECCNT,
        STAT, NOTE, SNDTIME, LAUNCH, LSTMODIFIER, LstUpdTime, GoOnChk)
      SELECT @n_Num, @v_SETTLENO, @SRC, FILLER, FILDATE, CHECKER, CHKDATE, RECCNT,
        0, NOTE, SNDTIME, LAUNCH, LSTMODIFIER, LstUpdTime, GoOnChk
      FROM NBILLTOADJ(NOLOCK)
      WHERE SRC = @SRC AND ID = @ID

      INSERT INTO BILLTOADJDTL(NUM, LINE, GDGID, OBILLTO, NBILLTO, NOTE)
      SELECT @n_Num, N.Line, X.LGid, N.OBillTo, N.NBillTo, N.Note
      FROM NBILLTOADJDTL N, GDXLATE X
        WHERE N.ID = @ID and N.GdGid *= X.NGid

      INSERT INTO BILLTOADJFEEDBCKDTL(NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE)
      SELECT NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE
      FROM NBILLTOADJFEEDBCKDTL(NOLOCK)
        WHERE SRC = @SRC AND ID = @ID
      --写生效门店
      INSERT INTO BILLTOADJLACDTL(NUM, STOREGID)
      VALUES(@n_Num, @v_UserGid)

      EXEC @v_Ret = BILLTOADJCHK @n_Num, '1', 100, @Oper, @Msg OUTPUT
      IF @v_Ret <> 0 RETURN @v_Ret
    END
  END ELSE
  --总部接收
  BEGIN
    SELECT @v_BckStat = STAT FROM NBILLTOADJFEEDBCKDTL(NOLOCK) WHERE ID = @ID AND SRC = @SRC
    --bckstat为已生效时，更新本地
    IF @v_BckStat = 3
      DELETE FROM BILLTOADJFEEDBCKDTL WHERE NUM = @n_Num AND STOREGID = @SRC

    INSERT INTO BILLTOADJFEEDBCKDTL(NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE)
    SELECT NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE
    FROM NBILLTOADJFEEDBCKDTL(NOLOCK)
      WHERE SRC = @SRC AND ID = @ID AND STAT = 3

    UPDATE BILLTOADJFEEDBCKDTL SET BILLTOADJFEEDBCKDTL.STAT = N.STAT
    FROM NBILLTOADJFEEDBCKDTL N(NOLOCK)
    WHERE BILLTOADJFEEDBCKDTL.NUM = @n_Num AND BILLTOADJFEEDBCKDTL.STOREGID = @SRC
      AND N.ID = @ID AND N.SRC = @SRC AND N.GDGID = BILLTOADJFEEDBCKDTL.GDGID
  END

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[接收]接收' + @n_Num + '单据失败'
    RETURN 5
  END

  delete from NBILLTOADJ where Id = @ID
  delete from NBILLTOADJDTL where Id = @ID
  delete from NBILLTOADJFEEDBCKDTL where ID = @ID

  SET @MSG = '[接收]接收' + @n_Num + '单据成功'

  RETURN 0
end
GO
