SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_UPDATE_NEXT_CYCLE] (
  @piCntrNum varchar(14),           --合约号
  @piCntrVersion integer,           --合约版本号
  @piCntrLine integer,              --合约行号
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vChgCls varchar(20)
  declare @vLstEndDate datetime
  declare @vFeeUnit varchar(20)
  declare @vFeeCycle integer
  declare @vFeeDayOffset integer
  declare @vBeginDate datetime
  declare @vEndDate datetime
  declare @vMessage varchar(255)
  declare @monthEndDate int

  select @vChgCls = f.CHGCLS
  from CTCHGDEF f, CTCNTRDTL d
  where d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine and d.CHGCODE = f.CODE

  if @vChgCls = '固定'
  begin
    set @vBeginDate = null
    set @vEndDate = null
  end else
  begin
    select 
      @vLstEndDate = NEXTENDDATE, 
      @vFeeUnit = FEEUNIT, 
      @vFeeCycle = FEECYCLE,
      @vFeeDayOffset = FEEDAYOFFSET
    from CTCNTRRATEDTL
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

    if @vLstEndDate is null
    begin
      set @vBeginDate = null
      set @vEndDate = null
    end else
      set @vBeginDate = @vLstEndDate + 1

    if @vFeeUnit = '日'
      set @vEndDate = @vLstEndDate + @vFeeCycle
    else if @vFeeUnit = '月'
    begin
      set @vEndDate = @vLstEndDate - day(@vLstEndDate) + 1
      set @vEndDate = dateadd(month, @vFeeCycle, @vEndDate)
      set @vEndDate = @vEndDate - day(@vEndDate) + 1
      if @vFeeDayOffset < 0
      begin
        set @vEndDate = dateadd(month, 1, @vEndDate)
        if month(@vEndDate) = 1 set @monthEndDate = 13
        else set @monthEndDate = month(@vEndDate)
        if month(@vEndDate + @vFeeDayOffset) + 1 < @monthEndDate
          set @vEndDate = dateadd(month, -1, @vEndDate)
        else
          set @vEndDate = @vEndDate + @vFeeDayOffset
      end
      else if @vFeeDayOffset = 0
        set @vEndDate = dateadd(month, 1, @vEndDate) - 1
      else if month(@vEndDate + @vFeeDayOffset) > month(@vEndDate)
        set @vEndDate = dateadd(month, 1, @vEndDate) - 2
      else
        set @vEndDate = @vEndDate + @vFeeDayOffset - 1
    end else if @vFeeUnit = '年'
    begin
      set @vEndDate = @vLstEndDate - day(@vLstEndDate) + 1
      set @vEndDate = dateadd(month, 12 * @vFeeCycle, @vEndDate)
        set @vEndDate = @vEndDate - day(@vEndDate) + 1
      if @vFeeDayOffset = 0
        set @vEndDate = dateadd(month, 1, @vEndDate) - 1
      else if month(@vEndDate + @vFeeDayOffset) > month(@vEndDate)
        set @vEndDate = dateadd(month, 1, @vEndDate) - 2
      else
        set @vEndDate = @vEndDate + @vFeeDayOffset - 1
    end else
    begin
      set @poErrMsg = '无法识别的费用统计周期单位: ' + @vFeeUnit
      return(1)
    end
  end

  --更新合约明细
  select @vMessage = convert(varchar(10), @vBeginDate, 102) + ' - ' + convert(varchar(10), @vEndDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Update_Next_Cycle', @vMessage
  if @vChgCls = '固定'
    update CTCNTRFIXDTL set
      NEXTBEGINDATE = @vBeginDate,
      NEXTENDDATE = @vEndDate
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  else
    update CTCNTRRATEDTL set
      NEXTBEGINDATE = @vBeginDate,
      NEXTENDDATE = @vEndDate
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  
  return(0)
end
GO
