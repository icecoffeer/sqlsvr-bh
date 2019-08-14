SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   procedure [dbo].[PROCTRANSFER_STAT_TO_110] (
  @piNum varchar(14),                 --单号
  @piOper varchar(80),                --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare
    @vSettleNo int, @vNewNum varchar(14), @vFromEqualTo int, @GdGid int, @Qty decimal(24, 4),
    @DispatchPrc money, @FromWrh int, @ToWrh int, @FromInvPrc money, @ToInvPrc money,
    @g_rtlprc money, @Sale int, @g_inprc money, @vRet int, @outcost money,
    @Amount money, @vTaskNum varchar(14), @vPscpGid int, @vQty decimal(24, 2), @vCount int,
    @vTotal money, @vSum money, @curdate datetime


  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  exec GenNextBillNumEx '', 'PROCTRANSFER', @vNewNum output
  insert into ProcTransfer(Num, SettleNo, Stat, TaskNum, RecCnt, Total, Note, Filler, FilDate,
    Checker, ChkTime, Modifier, LstUpdTime, Src)  select @vNewNum, @vSettleNo, 120, TaskNum, -RecCnt, -Total, @piNum, @piOper, getdate(),
    @piOper, getdate(), @piOper, getdate(), Src from ProcTransfer(nolock) where Num = @piNum
  insert into ProcTransferDtl(Num, Line, GdGid, Qty, DisPatchPrc, ToInvPrc, ToQty, FromInvPrc, FromQty, FromWrh, ToWrh)
    select @vNewNum, Line, GdGid, -Qty, DisPatchPrc, ToInvPrc, ToQty, FromInvPrc, FromQty, FromWrh, ToWrh from ProcTransferDtl(nolock) where Num = @piNum
  select @vFromEqualTo = Convert(int, OptionValue) from HDOption(nolock) where ModuleNo = 674 and OptionCaption = 'FROMEQUALTO'
  if @@RowCount = 0
    set @vFromEqualTo = 1

  declare c_Dtl cursor for
    select GdGid, Qty, DispatchPrc, FromWrh, ToWrh, FromInvPrc, ToInvPrc from ProcTransferDtl where Num = @piNum
  open c_Dtl
  fetch next from c_Dtl into @GdGid, @Qty, @DispatchPrc, @FromWrh, @ToWrh, @FromInvPrc, @ToInvPrc
  while @@fetch_status = 0
  begin
    select @g_rtlprc = RtlPrc, @Sale = Sale, @g_inprc = InPrc from goods(nolock) where Gid = @GdGid
    set @vRet = 0
    --increase inv
    exec @vRet = loadin @FromWrh, @GdGid, @Qty, @g_rtlprc, null
    if @vRet <> 0
    begin
      set @poErrMsg = '作废操作失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end

    if @vFromEqualTo = 1
    begin
      set @Amount = @FromInvPrc * @Qty
    end else
    begin
      set @Amount = @DispatchPrc * @Qty
    end
    exec @vRet = UPDINVPRC '内部调拨进', @GdGid, @Qty, @Amount, @FromWrh, 0
    if @vRet <> 0
    begin
      set @poErrMsg = '更新库存价失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end
    exec @vRet = UPDINVPRC '内部调拨出', @GdGid, @Qty, 0, @ToWrh, @outcost output
    if @vRet <> 0
    begin
      set @poErrMsg = '更新库存价失败.'
      close c_Dtl
      deallocate c_Dtl
      return(1)
    end
    exec @vRet = unload @ToWrh, @GdGid, @Qty, @g_rtlprc, null
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
        values (@curdate, @vSettleNo, @ToWrh, @GdGid, 1, 1, @Qty, @Amount, @outcost, @Qty * @g_rtlprc)

      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
        values (@curdate, @vSettleNo, @FromWrh, @GdGid, 1, 1, @Qty, @Amount, @Amount, @Qty * @g_rtlprc )
    end else
    begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDC_Q, NDC_A, NDC_I, NDC_R)
        values (@curdate, @vSettleNo, @ToWrh, @GdGid, 1, 1, @Qty, @Amount, @Qty * @g_inprc, @Qty * @g_rtlprc)

      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID, NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
        values (@curdate, @vSettleNo, @FromWrh, @GdGid, 1, 1, @Qty, @Amount, @Amount, @Qty * @g_rtlprc )
    end


    select @vCount = Count(1) from ProcTask(nolock) where Num = @vTaskNum
    if @vCount = 1
    begin
      select @vCount = Count(1) from ProcTaskRaw(nolock) where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh
      if @vCount = 1
      begin
        update ProcTaskRaw set MoveQty = MoveQty - @Qty where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh
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
            update ProcTaskRaw set MoveQty = MoveQty - @vQty/@vTotal*@Qty where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh and PscpGid = @vPscpGid
          end else
            update ProcTaskRaw set MoveQty = MoveQty - @Qty + @vSum where Num = @vTaskNum and GdGid = @GdGid and Wrh = @FromWrh and PscpGid = @vPscpGid
          select @vCount = @vCount - 1
          fetch next from c_UpdateQty into @vPscpGid, @vQty
        end
        close c_UpdateQty
        deallocate c_UpdateQty
      end;
    end

    fetch next from c_Dtl into @GdGid, @Qty, @DispatchPrc, @FromWrh, @ToWrh, @FromInvPrc, @ToInvPrc
  end
  close c_Dtl
  deallocate c_Dtl

  update ProcTransfer set  STAT = 110, MODIFIER = @piOper, LSTUPDTIME = getdate() where NUM = @piNum
  exec PROCTRANSFER_ADD_LOG @piNum, 100, 110, @piOper
  return(0)
end
GO
