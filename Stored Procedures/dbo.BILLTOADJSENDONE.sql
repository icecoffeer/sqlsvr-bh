SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BILLTOADJSENDONE]
(
    @Num  varchar(14),              --商品缺省供应商调整单号
    @rcv int,                       --接收单位
    @frcchk smallint,               --接收方是否强制审核
    @Msg varchar(256) output        --出错信息
) as
begin
  DECLARE
    --@STAT INT,
    @SRC INT,
    @ZBGID INT,
    @ID INT,
    @m_Note varchar(100),
    @v_OptUseFeedBck int --启用门店反馈机制

  exec OptReadInt 776, 'UseStFeedBck', 0, @v_OptUseFeedBck output

  SELECT @SRC = USERGID, @ZBGID = ZBGID FROM FASYSTEM(NOLOCK)
  --SELECT @STAT = STAT FROM BILLTOADJ(NOLOCK) WHERE NUM = @NUM

  /*IF @STAT <> 100
  BEGIN
    SET @Msg = '[发送]单据' + @NUM + '不是已审核状态'
    RETURN 1
  END*/

  --在总部发送才判断生效门店
  IF (@SRC = @ZBGID) AND NOT EXISTS(SELECT 1 FROM BILLTOADJLACDTL(NOLOCK) WHERE NUM = @NUM AND STOREGID = @RCV)
  BEGIN
    SELECT @m_Note = RTRIM(NAME) +'['+RTRIM(CODE)+']' FROM STORE WHERE GID = @rcv
    SELECT @m_Note ='单号为' + @num + '的单据不在门店' + rtrim(@m_Note) +'生效。'
    SET @Msg = @m_Note
    RETURN(1)
  END

  DELETE NBILLTOADJDTL
  FROM NBILLTOADJ M(NOLOCK)
    WHERE M.ID = NBILLTOADJDTL.ID AND M.SRC = NBILLTOADJDTL.SRC
      AND M.RCV = @rcv AND M.SRC = @SRC AND M.NUM = @Num
  --删除网络反馈明细数据
  DELETE NBILLTOADJFEEDBCKDTL
  FROM NBILLTOADJ M(NOLOCK)
    WHERE M.ID = NBILLTOADJFEEDBCKDTL.ID AND M.SRC= NBILLTOADJFEEDBCKDTL.SRC
      AND M.RCV = @rcv AND M.SRC = @SRC AND M.NUM = @Num
  delete from NBILLTOADJ where num = @num and rcv = @rcv

  UPDATE BILLTOADJ SET SNDTIME = GETDATE() WHERE NUM = @Num

  execute GetNetBillId @ID output
  INSERT INTO NBILLTOADJ(ID, NUM, SETTLENO, FILLER, FILDATE, CHECKER, CHKDATE, RECCNT,
    STAT, NOTE, LAUNCH, LSTMODIFIER, LstUpdTime, NSTAT, NNOTE, SRC, RCV, RCVTIME, FRCCHK, TYPE, GoOnChk, SNDTIME)
  SELECT  @ID, NUM, SETTLENO, FILLER, FILDATE, CHECKER, CHKDATE, RECCNT,
    STAT, @m_Note, LAUNCH, LSTMODIFIER, LstUpdTime, 0, NULL, @SRC, @rcv, NULL, @frcchk, 0, GoOnChk, SNDTIME
  FROM BILLTOADJ(NOLOCK)
    WHERE NUM = @NUM

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[发送]发送' + @Num + '单据汇总失败'
    RETURN(1)
  END

  INSERT INTO NBILLTOADJDTL(SRC, ID, NUM, LINE, GDGID, OBILLTO, NBILLTO, NOTE)
  SELECT @SRC, @ID, @NUM, LINE, GDGID, OBILLTO, NBILLTO, NOTE
  FROM BILLTOADJDTL(nolock) WHERE NUM = @Num

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[发送]发送' + @Num + '单据明细失败'
    RETURN(1)
  END
  --写网络反馈明细数据
  if @v_OptUseFeedBck = 1
  begin
    if (@SRC = @ZBGID) --总部发送时筛选STOREGID为RCV方的反馈数据
	    INSERT INTO NBILLTOADJFEEDBCKDTL (NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE, SRC, ID)
	    SELECT NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE, @SRC, @ID
	      FROM BILLTOADJFEEDBCKDTL(NOLOCK)
	    WHERE NUM = @NUM AND STOREGID = @rcv
	  else --门店发送给总部时不做筛选
	    INSERT INTO NBILLTOADJFEEDBCKDTL (NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE, SRC, ID)
	    SELECT NUM, LINE, STOREGID, GDGID, STAT, RTNNOTE, @SRC, @ID
	      FROM BILLTOADJFEEDBCKDTL(NOLOCK)
	    WHERE NUM = @NUM
  end

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[发送]发送' + @Num + '单据反馈明细失败'
    RETURN(1)
  END

  return(0)
end
GO
