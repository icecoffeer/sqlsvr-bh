SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BILLTOADJSEND]
(
    @Num  varchar(14),              --商品缺省供应商调整单号
    --@rcv int,                       --接收单位
    --@frcchk smallint,               --接收方是否强制审核
    @Msg varchar(256) output        --出错信息
) as
begin
  DECLARE
    @STAT INT,
    @lac_storeGid int,
    @usergid int,
    @zbgid int,
    @return_status int,
    @v_OptUseFeedBck int --是否启用门店反馈机制

  exec OptReadInt 776, 'UseStFeedBck', 0, @v_OptUseFeedBck output

  if @v_OptUseFeedBck <> 1
  begin
    if exists(select 1 from FASYSTEM(nolock) where zbgid <> usergid)
    begin
      SET @Msg = '非总部单位不能发送该单据'
      RETURN 1
    end
  end

  SELECT @STAT = STAT FROM BILLTOADJ(NOLOCK) WHERE NUM = @NUM
  IF @STAT = 0
  BEGIN
    SET @Msg = '[发送]单据' + @NUM + '不是可发送状态'
    RETURN 1
  END

  select @return_status = 0
  select @usergid = USERGID, @zbgid = ZBGID from FASYSTEM(nolock)
  --增加门店反馈
  IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID <> ZBGID) --门店发送
  BEGIN
    if (@v_OptUseFeedBck = 1)
    begin
      EXEC @return_status = BILLTOADJSENDONE @Num, @zbgid, 1, @Msg OUTPUT
      IF @return_status <> 0
        return @return_status
    end
  END
  ELSE
  BEGIN
    DECLARE c_Lac1 CURSOR FOR
      SELECT StoreGid FROM BILLTOADJLACDTL(nolock) WHERE Num = @num
        AND StoreGid <> @usergid
    OPEN c_Lac1
    FETCH NEXT FROM c_Lac1 INTO @lac_storeGid
    WHILE @@FETCH_STATUS = 0
    BEGIN
      EXEC @return_status = BILLTOADJSENDONE @num, @lac_storeGid, 1, @Msg OUTPUT
      IF @return_status <> 0 BREAK
      FETCH NEXT FROM c_Lac1 INTO @lac_storeGid
    END

    CLOSE c_Lac1
    DEALLOCATE c_Lac1
  END

  return(@return_status)
end
GO
