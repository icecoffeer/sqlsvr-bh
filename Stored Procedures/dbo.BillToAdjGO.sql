SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BillToAdjGO]
(
  @num  varchar(14),
  @Oper varchar(30)
  --@GoOnChk int
) as
begin
  declare
    @Line int,
    @OBillTo int,
    @NBillTo int,
    @GDGid int,
    @usergid int,
    @cur_settleno int,
    @curStat int,
    @storeGid int,
    @v_Ret Int,
    @v_OptUseFeedBck int --启用门店反馈机制

  exec OptReadInt 776, 'UseStFeedBck', 0, @v_OptUseFeedBck output

  select @curStat = STAT from BillToAdj(nolock) where NUM = @num
  if @curStat <> 100
    RETURN 1

  select @usergid = usergid from FASYSTEM(nolock)
  --如果审核时生效
  --if @GoOnChk = 0
  --如果在本店生效则影响商品表的缺省供应商
  if exists(select 1 from BILLTOADJLACDTL(nolock) where storegid = @usergid and num = @num)
  begin
    If (@v_OptUseFeedBck = 1) and Exists(Select 1 from System where ZBGID <> USERGID)
    begin
      --生效前判断是否有商品不能生效(如存在未审核的损耗\溢余单等),如有则退出
      Exec @v_Ret = BillToAdj_ValidGdDtl @num
      if @v_Ret <> 0 Return @v_Ret
      --门店生效时生成对应的退货单
      Exec @v_Ret = BillToAdj_GenDirIn @num, @Oper, 1
      if @v_Ret <> 0 Return @v_Ret
      Exec @v_Ret = BillToAdj_GenWhsBill @num, @Oper, 1
      if @v_Ret <> 0 Return @v_Ret
    end
    --修改商品表的缺省供应商字段
    declare c_Goods cursor for
      select OBillTo, NBillTo, GDGid from BillToAdjDtl(nolock) where Num = @num
    open c_Goods
    fetch next from c_Goods into @OBillTo, @NBillTo, @GDGid
    while @@fetch_status = 0
    begin
      if @OBillTo <> @NBillTo
        update GOODS set BillTo = @NBillTo where Gid = @GDGid
      fetch next from c_Goods into @OBillTo, @NBillTo, @GDGid
    end
    close c_Goods
    deallocate c_Goods
    --生效供应商后生成正向单据
    If (@v_OptUseFeedBck = 1) and Exists(Select 1 from System where ZBGID <> USERGID)
    begin
      Exec @v_Ret = BillToAdj_GenDirIn @num, @Oper, 0
      if @v_Ret <> 0 Return @v_Ret
      Exec @v_Ret = BillToAdj_GenWhsBill @num, @Oper, 0
      if @v_Ret <> 0 Return @v_Ret
    end
  end

  If Exists(Select 1 from System where ZBGID = USERGID)--总部才更新
  begin
    --同步更新gdstore表
    if object_id('BillToAdj_C3') is not null deallocate BillToAdj_C3
    declare BillToAdj_C3 cursor for
    select C.STOREGID, L.GDGID, L.OBILLTO, L.NBILLTO from BILLTOADJLACDTL C(nolock), BILLTOADJDTL L(nolock) where C.NUM = @num AND L.NUM = @num
    open BillToAdj_C3
    fetch next from BillToAdj_C3 into @STOREGID, @GDGid, @OBillTo, @NBillTo
    while @@FETCH_STATUS=0
    begin
      if not exists(select 1 from GDSTORE where STOREGID = @STOREGID and GDGID = @GDGID)
      begin
       insert into GDSTORE(STOREGID, GDGID, BILLTO, SALE, RTLPRC, INPRC, LOWINV, HIGHINV, PROMOTE, GFT, LWTRTLPRC, MBRPRC, DXPRC,
         PAYRATE, ISLTD, CNTINPRC, BQTYPRC, ALC, TopRtlPrc, ALCQTY, INVLOWBOUND, INVHIGHBOUND, ALCCTR, SALCQTY, SALCQSTART)
       select @storeGid, GID, @NBillTo, SALE, RTLPRC, INPRC, LOWINV, HIGHINV, PROMOTE, GFT, LWTRTLPRC, MBRPRC, DXPRC,
         PAYRATE, ISLTD, CNTINPRC, BQTYPRC, ALC, TopRtlPrc, isnull(ALCQTY, 0), LOWINV, HIGHINV, ALCCTR, SALCQTY, SALCQSTART
       from GOODS where GID = @GDGid
      end

      --if @OBillTo <> @NBillTo
      /*Modified by zhangzhen 此时各店商品中的billto可能与新的billto不同,那么也应该更新,因此去掉判断条件*/
      update GDSTORE set BILLTO = @NBillTo where STOREGID = @storeGid AND GDGID = @GDGid

      FETCH NEXT FROM BillToAdj_C3 INTO @storeGid, @GDGid, @OBillTo, @NBillTo
    END
    CLOSE BillToAdj_C3
    DEALLOCATE BillToAdj_C3
  end

  select @cur_settleno = max(NO) from MONTHSETTLE
  update BillToAdj set STAT = 800, SETTLENO = @cur_settleno where NUM = @num
  exec BillToAdj_ADD_LOG @Num, @curStat, 800, @Oper

  Return 0
end
GO
