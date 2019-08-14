SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PAYCASH_ALLOW_INPUT] (  
  @piCls varchar(20),                     --单据类型  
  @piNum varchar(14),                     --单号  
  @piOperGid int,                         --操作员  
  @poErrMsg varchar(255) output           --错误信息  
) as  
begin  
  declare @vPayCashNum varchar(14)  
  declare @vStat int  
  declare @vPayTotal money  
  declare @vTotal money  
  
  --检查状态  
  if @piCls = '供应商结算单'  
  begin  
    select @vStat = STAT, @vTotal = AMT, @vPayTotal = PYTOTAL  
    from PAY where NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 1  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已审核状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '代销结算单'  
  begin  
    select @vStat = STAT, @vTotal = AMT, @vPayTotal = PAYTOTAL  
    from SVI where CLS = '代销' and NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 1  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已审核状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '联销结算单'  
  begin  
    select @vStat = STAT, @vTotal = AMT, @vPayTotal = PAYTOTAL  
    from SVI where CLS = '联销' and NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 1  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已审核状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '发票'  
  begin  
    select @vStat = STAT, @vTotal = INVTOTAL, @vPayTotal = INVPAIDAMT  
    from INVOICE(nolock) where NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if (@vStat <> 600) and (@vStat <> 904)  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已复核或付款中状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '费用单'  
  begin  
    select @vStat = STAT, @vTotal = REALAMT, @vPayTotal = PAYTOTAL  
    from CHGBOOK where NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 500  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已审核状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '预付款单'  
  begin  
    select @vStat = STAT, @vTotal = TOTAL, @vPayTotal = TOTALOFF  
    from CNTRPREPAY where NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 900  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已付款状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '压库金额收款单'  
  begin  
    select @vStat = STAT, @vTotal = TOTAL, @vPayTotal = 0  
    from CNTRDPTBILL where cls = '收' and NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 1800  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已收款状态。'  
      return(1)  
    end  
  end  
  else if @piCls = '抵扣货款单'  
  begin  
    select @vStat = STAT, @vTotal = REALAMT, @vPayTotal = PAYTOTAL  
    from PGFBOOK where NUM = @piNum  
    if @@rowcount = 0  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不存在。'  
      return(1)  
    end  
    if @vStat <> 500  
    begin  
      set @poErrMsg = @piCls + ' ' + @piNum + ' 不是已审核状态。'  
      return(1)  
    end  
  end  
  else  
  begin  
    set @poErrMsg = '不能识别的单据类型: ' + @piCls  
    return(1)  
  end  
  
  --检查单据是否付清  
  if @vPayTotal >= @vTotal  
  begin  
    set @poErrMsg = @piCls + ' ' + @piNum + ' 已经付清。'  
    return(1)  
  end  
  
  --检查单据是否已经被其他未审核、已审核的付款单引用  
  select top 1 @vPayCashNum = m.NUM  
  from CNTRPAYCASH m, CNTRPAYCASHDTL d  
  where m.NUM = d.NUM  
    and m.STAT in (0, 2100, 2200, 2300, 100)  
    and d.CHGTYPE = @piCls  
    and d.IVCCODE = @piNum  
  if @vPayCashNum is not null  
  begin  
    set @poErrMsg = @piCls + ' ' + @piNum + ' 已被付款单 ' + @vPayCashNum + ' 引用。'  
    return(1)  
  end  
  
  return(0)  
end  

GO
