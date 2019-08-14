SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[BillToAdjRcv]
(
  @Src int,                 --来源单位
  @ID int,                  --网络ID
  @Oper Char(30),           --操作人
  @Msg VARCHAR  (255) OUTPUT  --出错信息
) as
begin
  declare
    @type int,
    @cnt int,
    @n_num char(14),
    @line int,
    @n_frcchk smallint,
    @settleno int,
    @GdGid int,
    @OBillTo int,
    @NBillTo int,
    @Note varchar(100),
    @Ret int,
    @v_OptUseFeedBck INT --是否启用门店反馈选项

  exec OptReadInt 776, 'UseStFeedBck', 0, @v_OptUseFeedBck output

  select @type = TYPE from NBILLTOADJ(nolock) where SRC = @Src and ID = @ID
  if @@rowcount <1
  begin
    set @Msg ='未找到指定网络商品缺省供应商调整单'
    update NBILLTOADJ set NSTAT = 1, NNOTE = @Msg where SRC = @Src and id = @ID
    return 1
  end
  if @type <> 1
  begin
    set @Msg ='不是可接收单据'
    update NBILLTOADJ set NSTAT = 1,NNOTE = @Msg where SRC = @Src and id = @ID
    return 1
  end
  --如果启用门店反馈,那么调用新的接收过程处理
  if @v_OptUseFeedBck = 1
  begin
    Exec @Ret = BillToAdjRcv_FeedBck @Src, @ID, @Oper, @Msg OUTPUT
    if @Ret <> 0 Return @Ret

    Return 0
  end

  select @cnt = sum(case when X.LGid is null then 1 else 0 end)
    from NBILLTOADJDTL N, GDXLATE X
    where N.Id = @ID and
    N.GdGid *= X.NGid
  if @cnt > 0
  begin
    set @Msg = '本地未包含商品资料'
    update NBILLTOADJ set NSTAT = 1,NNOTE = @Msg where SRC = @Src and id = @ID
    return 1
  end
  select @n_num = NUM, @n_frcchk = FrcChk from NBILLTOADJ(nolock) where SRC = @Src and id = @ID
  if exists(select * from BILLTOADJ(nolock) where num = @n_num)
  begin
    set @Msg='该单据已被接收过,不允许重复接收'
    update NBILLTOADJ set NSTAT = 1, NNOTE = @Msg where SRC = @Src and id = @ID
    return 1
  end
  select @settleno = max(no) from MONTHSETTLE(nolock)
  declare c_BilltoAdj_Rcv cursor for
    select N.Line, X.LGid, N.OBillTo, N.NBillTo, N.Note from NBILLTOADJDTL N, GDXLATE X
    where N.ID = @ID and N.GdGid *= X.NGid
  open c_BilltoAdj_Rcv
  fetch next from c_BilltoAdj_Rcv into @Line, @GdGid, @OBillTo, @NBillTo, @Note
  while @@fetch_status = 0
  begin
    insert into BILLTOADJDTL(NUM, LINE, GDGID, OBILLTO, NBILLTO, NOTE)
    values(@n_num, @Line, @GdGid, @OBillTo, @NBillTo, @Note)

    IF @@ERROR <> 0
    BEGIN
      SET @MSG = '[接收]接收' + @n_num + '单据失败'
      RETURN 2
    END

    fetch next from c_BilltoAdj_Rcv into @Line, @GdGid, @OBillTo, @NBillTo, @Note
  end
  close c_BilltoAdj_Rcv
  deallocate c_BilltoAdj_Rcv

  insert into BILLTOADJ(NUM, SETTLENO, SRC, FILLER, FILDATE, CHECKER, CHKDATE, RECCNT,
    STAT, NOTE, SNDTIME, LAUNCH, LSTMODIFIER, LstUpdTime, GoOnChk)
  select @n_num, @settleno, @Src, FILLER, FILDATE, CHECKER, CHKDATE, RECCNT,
    0, NOTE, SNDTIME, LAUNCH, LSTMODIFIER, LstUpdTime, GoOnChk --Edit by xiexinbin POS-1225 将STAT 修改为 0
  from NBILLTOADJ(nolock) where SRC = @Src and id = @ID

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[接收]接收' + @n_num + '单据失败'
    RETURN 2
  END
  --接收门店反馈明细
  INSERT INTO BILLTOADJFEEDBCKDTL(NUM, LINE, STOREGID, GDGID, STAT)
  SELECT NUM, LINE, STOREGID, GDGID, STAT
  FROM NBILLTOADJFEEDBCKDTL(NOLOCK)
  WHERE SRC = @SRC AND ID = @ID

  select @Oper = rtrim(CHECKER) from BILLTOADJ where NUM = @n_num  -- Add by xiexinbin POS-1225
  -- 写入生效单位
  DELETE FROM BILLTOADJLACDTL WHERE Num = @n_num
  DECLARE @storeGid int
  SELECT @storeGid = UserGid FROM FASYSTEM(nolock)
  INSERT INTO BILLTOADJLACDTL(Num, StoreGid) VALUES (@n_num, @storeGid)

  execute @ret = BILLTOADJCHK @n_num, '', 100, @Oper, @Msg OUTPUT
  if @ret <>0
    return @ret

  delete from NBILLTOADJ where Id = @ID
  delete from NBILLTOADJDTL where Id = @ID
  delete from NBILLTOADJFEEDBCKDTL where ID = @ID

  return 0
end
GO
