SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   procedure [dbo].[PROCTRANSFER_STAT_TO_100] (
  @piNum varchar(14),                 --单号
  @piOper varchar(80),                --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare
    @vSettleNo int,
    @GdGid int,
    @Qty money,
    @DispatchPrc money,
    @FromWrh int,
    @ToWrh int,
    @g_rtlprc money,
    @vRet int,
    @Sale int,
    @outcost money,
    @g_inprc money,
    @FromInvprc money,
    @ToInvprc money,
    @Amount money,
    @vCount int,
    @vTaskNum varchar(14),
    @vTotal money,
    @vPscpGid int,
    @vQty money,
    @vSum money,
    @curdate datetime,
    @vFromEqualTo int

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vTaskNum = TaskNum from ProcTransfer(nolock) where Num = @piNum
  select @vFromEqualTo = Convert(int, OptionValue) from HDOption(nolock) where ModuleNo = 674 and OptionCaption = 'FROMEQUALTO'
  if @@RowCount = 0
    set @vFromEqualTo = 1

  declare c_Dtl cursor for
    select GdGid, Qty, DispatchPrc, FromWrh, ToWrh from ProcTransferDtl where Num = @piNum
  open c_Dtl
  fetch next from c_Dtl into @GdGid, @Qty, @DispatchPrc, @FromWrh, @ToWrh
  while @@fetch_status = 0
  begin
    /*  跟新相应仓位库存价*/
    select @FromInvPrc = InvPrc from GdWrh(nolock) where GdGid = @GdGid and Wrh = @FromWrh
    if @@RowCount = 0
      select @FromInvPrc = InvPrc from Goods(nolock) where Gid = @GdGid
    select @ToInvPrc = InvPrc from GdWrh(nolock) where GdGid = @GdGid and Wrh = @ToWrh
    if @@RowCount = 0
      select @ToInvPrc = InvPrc from Goods(nolock) where Gid = @GdGid
    update ProcTransferDtl set FromInvPrc = @FromInvPrc, ToInvPrc = @ToInvPrc where Num = @piNum and GdGid = @GdGid


    select @g_rtlprc = RtlPrc, @Sale = Sale, @g_inprc = InPrc from goods(nolock) where Gid = @GdGid
    set @vRet = 0
    --reduce inv
    exec @vRet = unload @FromWrh, @GdGid, @Qty, @g_rtlprc, null
    if @vRet <> 0
    begin
      set @poErrMsg = '调出库存操作失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end

    exec @vRet = UPDINVPRC '内部调拨出', @GdGid, @Qty, 0, @FromWrh, @outcost output
    if @vRet <> 0
    begin
      set @poErrMsg = '更新库存价失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end
    if @vFromEqualTo = 1
      set @Amount = @outcost
    else
      set @Amount = @DispatchPrc * @Qty
    exec @vRet = UPDINVPRC '内部调拨进', @GdGid, @Qty, @Amount, @ToWrh, 0
    if @vRet <> 0
    begin
      set @poErrMsg = '更新库存价失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end
    exec @vRet = loadin @ToWrh, @GdGid, @Qty, @g_rtlprc, null
    if @vRet <> 0
    begin
      set @poErrMsg = '调入库存操作失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end

    select @curdate = getdate()
    if @Sale = 1
    begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDC_Q, NDC_A, NDC_I, NDC_R)
        values (@curdate, @vSettleNo, @FromWrh, @GdGid, 1, 1, @Qty, @Amount, @outcost, @Qty * @g_rtlprc)

      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
        values (@curdate, @vSettleNo, @ToWrh, @GdGid, 1, 1, @Qty, @Amount, @Amount, @Qty * @g_rtlprc )
    end else
    begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDC_Q, NDC_A, NDC_I, NDC_R)
        values (@curdate, @vSettleNo, @FromWrh, @GdGid, 1, 1, @Qty, @Amount, @Qty * @g_inprc, @Qty * @g_rtlprc)

      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
        values (@curdate, @vSettleNo, @ToWrh, @GdGid, 1, 1, @Qty, @Amount, @Amount, @Qty * @g_rtlprc )
    end

    select @vCount = Count(1) from ProcTask(nolock) where Num = @vTaskNum
    if @vCount = 1
    begin
      select @vCount = Count(1) from ProcTaskRaw(nolock) where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh
      if @vCount = 1
      begin
        update ProcTaskRaw set MoveQty = MoveQty + @Qty where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh
      end else if @vCount > 1
      begin
        select @vTotal = Sum(Qty) from ProcTaskRaw(nolock) where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh
        select @vSum = 0
        declare c_UpdateQty cursor for
          select PscpGid, Qty from ProcTaskRaw where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh
        open c_UpdateQty
        fetch next from c_UpdateQty into @vPscpGid, @vQty
        while @@fetch_status = 0
        begin
          if @vCount > 1
          begin
            select @vSum = @vSum + @vQty/@vTotal*@Qty
            update ProcTaskRaw set MoveQty = MoveQty + @vQty/@vTotal*@Qty where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh and PscpGid = @vPscpGid
          end else
            update ProcTaskRaw set MoveQty = MoveQty + @Qty - @vSum where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh and PscpGid = @vPscpGid
          select @vCount = @vCount - 1
          fetch next from c_UpdateQty into @vPscpGid, @vQty
        end
        close c_UpdateQty
        deallocate c_UpdateQty
      end;
    end

    fetch next from c_Dtl into @GdGid, @Qty, @DispatchPrc, @FromWrh, @ToWrh
  end
  close c_Dtl
  deallocate c_Dtl

  update ProcTransfer set
    STAT = 100,
    MODIFIER = @piOper,
    LSTUPDTIME = getdate(),
    SETTLENO = @vSettleNo,
    CHECKER = @piOper,
    CHKTIME = getdate()
  where NUM = @piNum
  exec PROCTRANSFER_ADD_LOG @piNum, 0, 100, @piOper

  return(0)
end
GO
