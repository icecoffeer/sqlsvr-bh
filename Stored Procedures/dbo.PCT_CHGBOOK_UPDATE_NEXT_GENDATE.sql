SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_UPDATE_NEXT_GENDATE] (
  @piCntrNum varchar(14),           --合约号
  @piCntrVersion integer,           --合约版本号
  @piCntrLine integer,              --合约行号
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare @vLstGenDate datetime
  declare @vNextGenDate datetime
  declare @vGenUnit varchar(10)
  declare @vGenCycle integer
  declare @vGenDayOffset integer
  declare @vGenMethod integer
  declare @vRealEndDate datetime
  declare @vMessage varchar(255)
  declare @monthNextGenDate int

  select @vRealEndDate = REALENDDATE
  from CTCNTR where NUM = @piCntrNum and VERSION = @piCntrVersion;
  select 
    @vGenMethod = f.GENMETHOD,
    @vLstGenDate = d.NEXTGENDATE,
    @vGenUnit = d.GENUNIT, 
    @vGenCycle = d.GENCYCLE, 
    @vGenDayOffset = d.GENDAYOFFSET
  from CTCNTRDTL d, CTCHGDEF f 
  where d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine and d.CHGCODE = f.CODE

  if @vGenMethod = 0  --固定周期
  begin
    if @vLstGenDate is null
      set @vNextGenDate = null
    else
    begin
      --如果上次生成日期已经超过实际截止日期，则不再生成
      if @vLstGenDate > @vRealEndDate
        set @vNextGenDate = null
      else
      begin
        if @vGenUnit = '日'
          set @vNextGenDate = @vLstGenDate + @vGenCycle
        else if @vGenUnit = '月'
        begin
          set @vNextGenDate = @vLstGenDate - day(@vLstGenDate) + 1
          set @vNextGenDate = dateadd(month, @vGenCycle, @vNextGenDate)
          if @vGenDayOffset < 0 
          begin
            set @vNextGenDate = dateadd(month, 1, @vNextGenDate)
            if month(@vNextGenDate) = 1 set @monthNextGenDate = 13
            else set @monthNextGenDate = month(@vNextGenDate)
            if month(@vNextGenDate + @vGenDayOffset) + 1 < @monthNextGenDate
            begin
              set @vNextGenDate = dateadd(month, -1, @vNextGenDate)
              if @vNextGenDate <= @vLstGenDate
                set @vNextGenDate = dateadd(month, 1, @vNextGenDate)
            end
            else begin
              set @vNextGenDate = @vNextGenDate + @vGenDayOffset
              if @vNextGenDate <= @vLstGenDate
                set @vNextGenDate = dateadd(month, 1, @vNextGenDate - @vGenDayOffset) + @vGenDayOffset
            end
          end
          else if month(@vNextGenDate + @vGenDayOffset - 1) > month(@vNextGenDate)
            set @vNextGenDate = dateadd(month, 1, @vNextGenDate) - 1
          else
            set @vNextGenDate = @vNextGenDate + @vGenDayOffset - 1
        end else if @vGenUnit = '年'
        begin
          set @vNextGenDate = @vLstGenDate - day(@vLstGenDate) + 1
          set @vNextGenDate = dateadd(month, 12 * @vGenCycle, @vNextGenDate)
          if month(@vNextGenDate + @vGenDayOffset - 1) > month(@vNextGenDate)
            set @vNextGenDate = dateadd(month, 1, @vNextGenDate) - 1
          else
            set @vNextGenDate = @vNextGenDate + @vGenDayOffset - 1
        end else
        begin
          set @poErrMsg = '无法识别的生成周期单位: ' + @vGenUnit
          return(1)
        end
      end
    end
  end else  --固定日
  begin
    select @vNextGenDate = min(GENDATE)
    from CTCNTRFIXDATE where NUM = @piCntrNum and VERSION = @piCntrVersion 
      and LINE = @piCntrLine and isnull(CHGBOOKNUM, '') = ''
    if @vNextGenDate is not null and @vNextGenDate > @vRealEndDate
      set @vNextGenDate = null
  end
    
  --更新合约明细
  select @vMessage = convert(varchar, @vNextGenDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Update_Next_GenDate', @vMessage
  update CTCNTRDTL set NEXTGENDATE = @vNextGenDate
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
    
  return(0)
end
GO
