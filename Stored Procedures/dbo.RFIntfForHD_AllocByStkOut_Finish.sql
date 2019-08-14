SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_AllocByStkOut_Finish](
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @piStkOutNum varchar(10),     --传入参数：配出单号。
  @poErrMsg varchar(255) output --传出参数：错误消息。返回值不为0时有效。
)
as
begin
  declare
    @return_status int,
    @StkOutIsProcessed int,
    @GdCnt int,
    @d_UUID varchar(38),
    @d_GdCode char(13),
    @d_PrevGdCode char(13),
    @d_Cases decimal(24,4),
    @d_Qty decimal(24,4),
    @d_OriQty decimal(24,4),
    @d_Price decimal(24,4),
    @d_FirstPrice decimal(24,4),
    @d_Total decimal(24,4),
    @d_Tax decimal(24,4),
    @g_Gid int,
    @g_Qpc decimal(24,4),
    @g_TaxRate decimal(24,4),
    @d_Line int,
    @d_PrevLine int,
    @Total decimal(24,4),
    @Tax decimal(24,4),
    @RecCnt int

  --检查配出单合法性，包括限制其状态必须为未审核。
  exec @return_status = RFIntfForHD_AllocByStkOut_ChkStkOutNum @piStkOutNum,
    @StkOutIsProcessed output, @poErrMsg output
  if @return_status <> 0
    return 1

  /*配货数以RF端的数据为准，因此先将配货单中所有商品的数量、含税金额、税
  额等属性的值全部清空为0。不更新单价。*/
  update STKOUTDTL set
    CASES = 0,
    QTY = 0,
    TOTAL = 0,
    TAX = 0
    where CLS = '配货'
    and NUM = @piStkOutNum

  /*逐条读取配货记录，并将数量和单价等属性的值更新到配出单明细中。对于同一个商
  品有多条配货记录的，其单价的取值以第一条为准（按操作时间升序排列）。*/
  declare c_RFAllocByStkOut cursor for
    select rf.UUID, rf.GDCODE, rf.QTY, rf.PRICE, g.GID, g.QPC, g.TAXRATE
    from RFALLOCBYSTKOUT rf
      inner join GOODS g on g.CODE = rf.GDCODE
    where rf.OPERATORCODE = @piEmpCode
    and rf.STKOUTNUM = @piStkOutNum
    and rf.FINISHTIME is null
    order by rf.GDCODE, rf.OPERATIONTIME
    for update
  open c_RFAllocByStkOut
  --获取第一条配货记录。
  fetch next from c_RFAllocByStkOut into @d_UUID, @d_GdCode, @d_Qty, @d_Price,
    @g_Gid, @g_Qpc, @g_TaxRate
  if @@fetch_status <> 0
  begin
    close c_RFAllocByStkOut
    deallocate c_RFAllocByStkOut
    set @poErrMsg = '尚未提交配货记录，不能进行结束配货的操作。'
    return 1
  end

  set @d_PrevGdCode = @d_GdCode
  set @d_FirstPrice = @d_Price
  while @@fetch_status = 0
  begin
    /*单价。对同一个商品来说，如果它在 RFALLOCBYSTKOUT 存在多条记录，则它的单价
    取第一条记录的单价（按操作时间升序排列）。*/
    if @d_GdCode <> @d_PrevGdCode
    begin
      set @d_PrevGdCode = @d_GdCode
      set @d_FirstPrice = @d_Price
    end
    --配货商品在配出单中存在的记录数。
    select @GdCnt = count(1) from STKOUTDTL(nolock)
      where CLS = '配货'
      and NUM = @piStkOutNum
      and GDGID = @g_Gid
    if @GdCnt = 0
    begin
      update RFALLOCBYSTKOUT set
        NOTE = '该商品不在配出单' + rtrim(@piStkOutNum) + '中。'
        where current of c_RFAllocByStkOut
    end
    else if @GdCnt = 1
    begin
      --行号、数量
      select @d_Line = LINE,
        @d_OriQty = QTY
        from STKOUTDTL(nolock)
        where CLS = '配货'
        and NUM = @piStkOutNum
        and GDGID = @g_Gid
      --箱数
      if isnull(@g_Qpc, 0) = 0
        set @g_Qpc = 1
      set @d_Cases = round((@d_Qty + @d_OriQty) / @g_Qpc, 3)
      --含税金额
      set @d_Total = round((@d_Qty + @d_OriQty) * @d_FirstPrice, 2)
      --税额
      set @d_Tax = round(@d_Total / (100 + @g_TaxRate) * @g_TaxRate, 2)
      --更新明细
      update STKOUTDTL set
        CASES = @d_Cases,
        QTY = @d_Qty + @d_OriQty,
        PRICE = @d_FirstPrice,
        TOTAL = @d_Total,
        TAX = @d_Tax
        where CLS = '配货'
        and NUM = @piStkOutNum
        and LINE = @d_Line
    end
    else begin
      update RFALLOCBYSTKOUT set
        NOTE = '该商品在配出单' + rtrim(@piStkOutNum) + '中存在2条以上的记录。暂时不支持对2条以上记录的更新。'
        where current of c_RFAllocByStkOut
    end
    --将使用过的记录转移到历史表中。
    update RFALLOCBYSTKOUT set
      FINISHTIME = getdate()
      where current of c_RFAllocByStkOut
    insert into RFALLOCBYSTKOUTH
      select * from RFALLOCBYSTKOUT(nolock)
      where UUID = @d_UUID
    --取下一条记录的信息。
    fetch next from c_RFAllocByStkOut into @d_UUID, @d_GdCode, @d_Qty, @d_Price,
      @g_Gid, @g_Qpc, @g_TaxRate
  end
  close c_RFAllocByStkOut
  deallocate c_RFAllocByStkOut

  --删除数量为0的记录，并重新设置行号使之连续。
  delete from STKOUTDTL
    where CLS = '配货'
    and NUM = @piStkOutNum
    and QTY = 0
  if @@rowcount > 0
  begin
    declare c_StkOutDtl cursor for
      select LINE from STKOUTDTL
      where CLS = '配货'
      and NUM = @piStkOutNum
      order by LINE
      for update
    open c_StkOutDtl
    fetch next from c_StkOutDtl into @d_Line
    set @d_PrevLine = 0
    while @@fetch_status = 0
    begin
      if @d_Line <> @d_PrevLine + 1
      begin
        update STKOUTDTL set
          LINE = @d_PrevLine + 1
          where current of c_StkOutDtl
      end
      set @d_PrevLine = @d_PrevLine + 1
      fetch next from c_StkOutDtl into @d_Line
    end
    close c_StkOutDtl
    deallocate c_StkOutDtl
  end
  --更新汇总信息。
  select @Total = sum(TOTAL),
    @Tax = sum(TAX),
    @RecCnt = count(*)
    from STKOUTDTL(nolock)
    where CLS = '配货'
    and NUM = @piStkOutNum
  if @RecCnt = 0
  begin
    set @poErrMsg = '尚未提交任何有效的配货记录，不能进行结束配货的操作。'
    return 1
  end
  update STKOUT set
    TOTAL = @Total,
    TAX = @Tax,
    RECCNT = @RecCnt,
    FILDATE = getdate(),
    NOTE = 'RF配货，操作人代码：' + rtrim(@piEmpCode) + '。'
    where CLS = '配货'
    and NUM = @piStkOutNum

  --将使用过的记录转移到历史表中。
  delete from RFALLOCBYSTKOUT
    where OPERATORCODE = @piEmpCode
    and STKOUTNUM = @piStkOutNum
    and FINISHTIME is not null
    and exists(select 1 from RFALLOCBYSTKOUTH(nolock) where RFALLOCBYSTKOUTH.UUID = RFALLOCBYSTKOUT.UUID)

  return 0
end
GO
