SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROMDLTONEGOODS]
(
 @piPromType  int,
 @piGDGid int,
 @piStart datetime,
 @piFinish datetime,
 @piOper varchar(30),
 @poErrMsg varchar(255) output
)
as

begin
  declare
    @vPromTypeStr varchar(20),
    @vBillNum varchar(14),
    @vBillLine int,
    @vFlag int,
    @vResult int,
    @vPrmNo int

  if @piPromType = 2
    set @vPromTypeStr = '组合'
  else if @piPromType = 4
    set @vPromTypeStr = '总额'
  else if @piPromType = 6
    set @vPromTypeStr = '捆绑'
  else if @piPromType = 8 ---非固定商品
    set @vPromTypeStr = '捆绑'
  else if @piPromType = 9 ---捆绑赠品
    set @vPromTypeStr = '捆绑'
  else if @piPromType = 11
    set @vPromTypeStr = '总量'
  else if @piPromType = 13
    set @vPromTypeStr = '数量'
  else if @piPromType = 14
    set @vPromTypeStr = '组合价'
  else if @piPromType = 15
    set @vPromTypeStr = '组合价'
  else if @piPromType = 16
    set @vPromTypeStr = '组合价'
  else begin
    set @poErrMsg = '传入参数促销模式错误！'
    return(1)
  end

  if @piPromType = 2
  begin
    declare curPromType cursor for
      select distinct BillNum, BillLine
      from Prices(nolock)
      where GDGid = @piGDGid and Cls = '组合'
        and AFinish > @piStart and AStart < @piFinish
        and Store in(select StoreGid from #TmpPromStoreList)
    open curPromType
    fetch next from curPromType into @vBillNum, @vBillLine
    while @@fetch_status = 0
    begin
      exec @vResult = PROMBDLTONE @vBillNum, '组合', @piGDGid, @vBillLine, @piOper, @poErrMsg output
      if @vResult <> 0
      begin
        close curPromType
        deallocate curPromType
        return(1)
      end
      fetch next from curPromType into @vBillNum, @vBillLine
    end
    close curPromType
    deallocate curPromType
    return(0)
  end else
  begin
    if @piPromType <> 8 ----只有在取消捆绑非固定商品的时候不做
    begin
      declare curPromGft cursor for
        select distinct BillNum, BillLine, Flag, PrmNo
        from PromoteGft(nolock)
        where Cls = @vPromTypeStr and GftGid = @piGDGid and Flag = 0
          and BillNum in(
            select distinct BillNum
            from Promote(nolock)
              where Cls = @vPromTypeStr
                and AFinish > @piStart and AStart < @piFinish
                and Store in(select StoreGid from #TmpPromStoreList)
                and BillNum in(select distinct BillNum from PromoteGft(nolock)
                   where GftGid = @piGDGid and Cls = @vPromTypeStr))
      open curPromGft
      fetch next from curPromGft into @vBillNum, @vBillLine, @vFlag, @vPrmNo
      while @@fetch_status = 0
      begin
        exec @vResult = PROMGFTDLTONE @vBillNum, @vPromTypeStr, @vPrmNo, @vFlag, @piGDGid, @vBillLine, @piOper, @poErrMsg output
        if @vResult <> 0
        begin
          close curPromGft
          deallocate curPromGft
          return(1)
        end
        fetch next from curPromGft into @vBillNum, @vBillLine, @vFlag, @vPrmNo
      end
      close curPromGft
      deallocate curPromGft
    end

    if @piPromType <> 9    ---只有在取消捆绑赠品的时候不做
    begin
      declare curPromType cursor for
        select distinct BillNum, BillLine, Flag
        from Promote(nolock)
        where Cls = @vPromTypeStr and GDGid = @piGDGid
          and AFinish > @piStart and AStart < @piFinish
          and Store in(select StoreGid from #TmpPromStoreList)

      open curPromType
      fetch next from curPromType into @vBillNum, @vBillLine, @vFlag
      while @@fetch_status = 0
      begin
        exec @vResult = PROMDLTONE @vBillNum, @vPromTypeStr, @piGDGid, @vBillLine, @vFlag, @piOper, @poErrMsg output
        if @vResult <> 0
        begin
          close curPromType
          deallocate curPromType
          return(1)
        end
        fetch next from curPromType into @vBillNum, @vBillLine, @vFlag
      end
      close curPromType
      deallocate curPromType
    end
    return(0)
  end
end
GO
