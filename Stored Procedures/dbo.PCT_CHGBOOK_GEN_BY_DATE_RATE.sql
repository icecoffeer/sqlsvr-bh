SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_GEN_BY_DATE_RATE] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piGenType integer,                     --生成方式
  @piGenDate datetime,                    --生成日期
  @piOperGid integer,                     --操作人
  @poErrMsg varchar(255) output,          --出错信息
  @piBegDate datetime = null,             --统计开始日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
  @piEndDate datetime = null              --统计截止日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
) as
begin
  declare @vRet integer
  declare @vTotal decimal(24, 2)
  declare @vBeginDate datetime
  declare @vEndDate datetime
  declare @vLstEndDate datetime
  declare @vBaseTotal decimal(24, 2)
  declare @vRateTotal decimal(24, 2)
  declare @vCalcRate decimal(24, 2)
  declare @vChgBookNum varchar(14)
  declare @vChgCode varchar(20)
  declare @vChgCls varchar(20)
  declare @vItemNo integer
  declare @vDate datetime
  declare @vDataSrc varchar(20)
  declare @vGenDate datetime
  declare @vRealEndDate datetime
  declare @vMessage varchar(255)
  declare @vNote varchar(255)
  declare @vFeeToStore integer
  declare @vStoreScope varchar(255)
  declare @vStoreScopeSql varchar(255)
  declare @vGdScopeSql varchar(255)
  declare @vCmd varchar(255)
  declare @vSqlCond varchar(255)
  declare @vStoreGid integer
  declare @vBegITEMNO int
  declare @vEndITEMNO int
  declare @vLOWDATE datetime
  declare @vHighDATE datetime
  declare @vGAMT decimal(24, 2)
  declare @vRateByMonth decimal(24, 2)
  declare @vTmpRateTotal decimal(24, 2)
  declare @vSign int
  declare @vRoundType varchar(20)
  declare @vFeePrec decimal(24, 2)
  declare @vBaseTotal2 decimal(24, 2)
  declare @vDefCycle int
  --固定提成类增加上限控制
  declare @vLimitTotal decimal(24, 2) --收取金额上限
  declare @vSumTotal decimal(24, 2) --累计收取金额
  declare @vCase smallint --提成方案

  set @vMessage = convert(varchar(10), @piGenDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Gen_By_Date_Rate', @vMessage

  select @vDate = convert(varchar, getdate(), 102)
  select
    @vChgCode = CHGCODE,
    @vCase = [CASE]
  from CTCNTRDTL
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  select @vChgCls = CHGCLS, @vDefCycle = DESIGNCYCLE from CTCHGDEF where CODE = @vChgCode
  select @vFeeToStore = FEETOSTORE from CTCHGDEFRATE where CODE = @vChgCode
  select @vRealEndDate = REALENDDATE from CTCNTR where NUM = @piCntrNum and VERSION = @piCntrVersion
  --上限
  select
    @vLimitTotal = LIMITTOTAL,
    @vSumTotal = SUMTOTAL
  from CTCNTRRATEDTL
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

  set @vLstEndDate = null
  while 1 = 1
  begin
    if @vDefCycle = 0 --不手工指定统计时间段
    begin
      --取得统计日期
      exec @vRet = PCT_CHGBOOK_NEXT_CYCLE @piCntrNum, @piCntrVersion, @piCntrLine,
        @vBeginDate output, @vEndDate output, @poErrMsg output
      if @vRet <> 0 return(@vRet)
      if @vBeginDate is null or @vEndDate is null return(0)
      if @vBeginDate > @vEndDate return(0)
      if @vEndDate >= @piGenDate return(0)
      if @vLstEndDate = @vEndDate
      begin
        set @poErrMsg = '合约 ' + @piCntrNum + ' 无法计算下次统计日期'
        return(1)
      end
      set @vLstEndDate = @vEndDate
    end else if @vDefCycle = 1
    begin
      set @vBeginDate = @piBegDate
      set @vEndDate = @piEndDate
      if @vBeginDate is null
        set @vBeginDate = '1900.12.31'
      if @vEndDate is null
        set @vEndDate = '2099.12.31'
    end

    --限制在合约的有效日期范围内
    if @vEndDate > @vRealEndDate
      set @vEndDate = @vRealEndDate

    set @vMessage = '提成类项目, 统计周期: ' + convert(varchar(10), @vBeginDate, 102) + ' - ' + convert(varchar(10), @vEndDate, 102)
    exec PCT_CHGBOOK_LOGDEBUG 'Gen_By_Date', @vMessage

    if @vFeeToStore = 1
    begin
      if substring(@vChgCode, 1, 2) <> '06'
      begin
        if object_id('c_RateStoreGd') is not null deallocate c_RateStoreGd
        declare c_RateStoreGd cursor for
          select ITEMNO, STORESCOPE, GDSCOPESQL, NOTE
          from CTCNTRRATESTOREGD where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
        open c_RateStoreGd
        fetch next from c_RateStoreGd into @vItemNo, @vStoreScope, @vGdScopeSql, @vNote
        while @@fetch_status = 0
        begin
          if object_id('c_Store') is not null deallocate c_Store
          select @vSqlCond = SQLCOND from CTSCOPE(nolock)
          where CATEGORY = '门店' and CODE = @vStoreScope
          set @vCmd = 'declare c_Store cursor for select GID from STORE where ' + @vSqlCond
          exec(@vCmd)
          open c_Store
          fetch next from c_Store into @vStoreGid
          while @@fetch_status = 0
          begin
            --计算统计基数
            set @vBaseTotal = 0
            if object_id('c_DataSrc') is not null deallocate c_DataSrc
            if exists (select 1 from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine)
              declare c_DataSrc cursor for
                select DSCODE from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
            else
              declare c_DataSrc cursor for
                select DSCODE from CTCHGDATASRC(nolock) where CODE = @vChgCode
            open c_DataSrc
            fetch next from c_DataSrc into @vDataSrc
            while @@fetch_status = 0
            begin
              exec @vRet = PCT_CHGBOOK_CALC_BASETOTAL2 @piCntrNum, @piCntrVersion, @piCntrLine, @vStoreGid, @vGdScopeSql,
                @vDataSrc, @vBeginDate, @vEndDate, @vTotal output, @poErrMsg output
              if @vRet <> 0 break

              set @vBaseTotal = @vBaseTotal + isnull(@vTotal, 0)
              fetch next from c_DataSrc into @vDataSrc
            end
            close c_DataSrc
            deallocate c_DataSrc
            if @vRet <> 0 break

            --计算提成金额
            exec @vRet = PCT_CHGBOOK_CALC_RATETOTAL2 @piCntrNum, @piCntrVersion, @piCntrLine, @vItemNo, @vBeginDate, @vEndDate, @vBaseTotal,
              @vRateTotal output, @vCalcRate output, @poErrMsg output
            if @vRet <> 0 break

            --如果是固定提成类(02),那么根据上限控制来重新计算@vRateTotal提成金额
            --if（本次定制数据源的提成金额+累计收取金额）>收取金额上限,then 收取金额上限-累计收取金额
            --然后更新"累计收取金额"
            if (substring(@vChgCode, 1, 2) = '02') and (@vLimitTotal > 0)
            begin
              if @vRateTotal + @vSumTotal > @vLimitTotal
                set @vRateTotal = @vLimitTotal - @vSumTotal

              update CTCNTRRATEDTL
                Set SUMTOTAL = SUMTOTAL + @vRateTotal
              where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
            end
            --end of 上限控制

            --创建费用单
            exec PCT_CHGBOOK_LOGRATERPT @piCntrNum, @piCntrVersion, @vChgCode, @vDate, @piGenDate, @vBeginDate, @vEndDate, @vBaseTotal, @vRateTotal
            exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK @vStoreGid, @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @piGenDate, @vBeginDate, @vEndDate,
              @vBaseTotal, @vRateTotal, @vCalcRate, null, @piGenDate, @vDate, @vNote, @vChgBookNum output, @piOperGid, @poErrMsg output

            if @vRet <> 0 break
            fetch next from c_Store into @vStoreGid
          end
          close c_Store
          deallocate c_Store

          if @vRet <> 0 break
          fetch next from c_RateStoreGd into @vItemNo, @vStoreScope, @vGdScopeSql, @vNote
        end
        close c_RateStoreGd
        deallocate c_RateStoreGd
      end else begin --substring(@vChgCode, 1, 2) = '06'
        if object_id('c_RateStoreGd') is not null deallocate c_RateStoreGd
        declare c_RateStoreGd cursor for
          select ITEMNO, STORESCOPE, GDSCOPESQL, NOTE
          from CTCNTRRATESTOREGD where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
        open c_RateStoreGd
        fetch next from c_RateStoreGd into @vItemNo, @vStoreScope, @vGdScopeSql, @vNote
        while @@fetch_status = 0
        begin
          if object_id('c_Store') is not null deallocate c_Store
          select @vSqlCond = SQLCOND from CTSCOPE(nolock)
          where CATEGORY = '门店' and CODE = @vStoreScope
          set @vCmd = 'declare c_Store cursor for select GID from STORE where ' + @vSqlCond
          exec(@vCmd)
          open c_Store
          fetch next from c_Store into @vStoreGid
          while @@fetch_status = 0
          begin
            set @vRateTotal = 0
            select @vBegITEMNO = ROWNO from CTCNTRRATEBYMONTHSTOREGDDISC
            where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
              and ITEMNO = @vItemNo
              and LOWDATE <= @vBeginDate and HIGHDATE > @vBeginDate
            set @vBegITEMNO = ISNULL(@vBegITEMNO, 1)
            select @vEndITEMNO = ROWNO - 1 from CTCNTRRATEBYMONTHSTOREGDDISC
            where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
              and ITEMNO = @vItemNo
              and LOWDATE <= @vEndDate and HIGHDATE > @vEndDate
            set @vEndITEMNO = ISNULL(@vEndITEMNO, 1)
            --if @vEndITEMNO = 0 set @vEndITEMNO = 1

            set @vBaseTotal2 = 0
            if object_id('c_DisByMonth') is not null deallocate c_DisByMonth
            declare c_DisByMonth cursor for
              select LOWDATE, HIGHDATE - 1, GAMT, RATE from CTCNTRRATEBYMONTHSTOREGDDISC
              where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
                and ITEMNO = @vItemNo
                and ROWNO >= @vBegITEMNO and ROWNO <= @vEndITEMNO
              order by LOWDATE
            open c_DisByMonth
            fetch next from c_DisByMonth into @vLOWDATE, @vHIGHDATE, @vGAMT, @vRateByMonth
            while @@fetch_status = 0
            begin
              --计算统计基数
              set @vBaseTotal = 0
              if object_id('c_DataSrc') is not null deallocate c_DataSrc
              if exists (select 1 from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine)
                declare c_DataSrc cursor for
                  select DSCODE from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
              else
                declare c_DataSrc cursor for
                  select DSCODE from CTCHGDATASRC(nolock) where CODE = @vChgCode
              open c_DataSrc
              fetch next from c_DataSrc into @vDataSrc
              while @@fetch_status = 0
              begin
                set @vDataSrc = '0' + substring(@vDataSrc, 2, 3)
                exec @vRet = PCT_CHGBOOK_CALC_BASETOTAL2 @piCntrNum, @piCntrVersion, @piCntrLine, @vStoreGid, @vGdScopeSql,
                  @vDataSrc, @vLOWDATE, @vHIGHDATE, @vTotal output, @poErrMsg output
                if @vRet <> 0 break

                set @vBaseTotal = @vBaseTotal + isnull(@vTotal, 0)
                fetch next from c_DataSrc into @vDataSrc
              end
              close c_DataSrc
              deallocate c_DataSrc
              if @vRet <> 0 break

              --如果CTCNTRRATEDTL.Case=1,那么使用定制的算法计算提成,否则保持原有逻辑
              if @vCase = 0
              begin
	              if @vBaseTotal >= @vGAMT set @vTmpRateTotal = 0
	              else set @vTmpRateTotal = (@vGAMT - @vBaseTotal) * @vRateByMonth / 100
	              set @vRateTotal = @vRateTotal + @vTmpRateTotal
	              if @vBaseTotal < @vGAMT set @vBaseTotal2 = @vBaseTotal2 + @vGAMT - @vBaseTotal
	            end
	            /*else begin
	              --项目定制,计算提成
	              --月租金-销售毛利
	            end*/

              fetch next from c_DisByMonth into @vLOWDATE, @vHIGHDATE, @vGAMT, @vRateByMonth
            end
            close c_DisByMonth
            deallocate c_DisByMonth
            set @vBaseTotal = isnull(@vBaseTotal, 0)
            set @vBaseTotal2 = isnull(@vBaseTotal2, 0)

            if @vRateTotal < 0
            begin
              set @vRateTotal = -@vRateTotal
              set @vSign = -1
            end else
              set @vSign = 1

            --精度处理
            select @vRoundType = ROUNDTYPE, @vFeePrec = FEEPREC
            from CTCNTRRATEDTL where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

            if @vRoundType = '四舍五入'
              set @vRateTotal = floor((@vRateTotal / @vFeePrec) + 0.5) * @vFeePrec
            else if @vRoundType = '进一'
              set @vRateTotal = ceiling(@vRateTotal / @vFeePrec) * @vFeePrec
            else if @vRoundType = '去尾'
              set @vRateTotal = floor(@vRateTotal / @vFeePrec) * @vFeePrec

            set @vRateTotal = @vSign * @vRateTotal

            select @vCalcRate = Max(RATE)
            from CTCNTRRATEBYMONTHSTOREGDDISC where NUM = @piCntrNum and VERSION = @piCntrVersion
              and LINE = @piCntrLine and ITEMNO = @vItemNo

            --创建费用单
            exec PCT_CHGBOOK_LOGRATERPT @piCntrNum, @piCntrVersion, @vChgCode, @vDate, @piGenDate, @vBeginDate, @vEndDate, @vBaseTotal2, @vRateTotal
            exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK @vStoreGid, @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @piGenDate, @vBeginDate, @vEndDate,
              @vBaseTotal2, @vRateTotal, @vCalcRate, null, @piGenDate, @vDate, @vNote, @vChgBookNum output, @piOperGid, @poErrMsg output

            if @vRet <> 0 break
            fetch next from c_Store into @vStoreGid
          end
          close c_Store
          deallocate c_Store

          if @vRet <> 0 break
          fetch next from c_RateStoreGd into @vItemNo, @vStoreScope, @vGdScopeSql, @vNote
        end
        close c_RateStoreGd
        deallocate c_RateStoreGd
      end
      if @vRet <> 0 return(@vRet)
    end else
    begin
      if substring(@vChgCode, 1, 2) <> '06'
      begin
        --计算统计基数
        set @vBaseTotal = 0
        if object_id('c_DataSrc') is not null deallocate c_DataSrc
        if exists (select 1 from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine)
          declare c_DataSrc cursor for
            select DSCODE from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
        else
          declare c_DataSrc cursor for
            select DSCODE from CTCHGDATASRC(nolock) where CODE = @vChgCode
        open c_DataSrc
        fetch next from c_DataSrc into @vDataSrc
        while @@fetch_status = 0
        begin
          exec @vRet = PCT_CHGBOOK_CALC_BASETOTAL @piCntrNum, @piCntrVersion, @piCntrLine, @vDataSrc,
            @vBeginDate, @vEndDate, @vTotal output, @poErrMsg output
          if @vRet <> 0 break
          set @vBaseTotal = @vBaseTotal + @vTotal

          fetch next from c_DataSrc into @vDataSrc
        end
        close c_DataSrc
        deallocate c_DataSrc
        if @vRet <> 0 break

        --计算提成金额
        exec @vRet = PCT_CHGBOOK_CALC_RATETOTAL @piCntrNum, @piCntrVersion, @piCntrLine, @vBeginDate, @vEndDate, @vBaseTotal,
          @vRateTotal output, @vCalcRate output, @poErrMsg output
        if @vRet <> 0 break

        --如果是固定提成类(02),那么根据上限控制来重新计算@vRateTotal提成金额
        --if（本次定制数据源的提成金额+累计收取金额）>收取金额上限,then 收取金额上限-累计收取金额
        --然后更新"累计收取金额"
        if (substring(@vChgCode, 1, 2) = '02') and (@vLimitTotal > 0)
        begin
          if @vRateTotal + @vSumTotal > @vLimitTotal
            set @vRateTotal = @vLimitTotal - @vSumTotal

          update CTCNTRRATEDTL
            Set SUMTOTAL = SUMTOTAL + @vRateTotal
          where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
        end
        --end of 上限控制
      end else begin --对于分段取保底金额和提成率('06')
        set @vRateTotal = 0
        --取得开始统计区间
        select @vBegITEMNO = ITEMNO from CTCNTRRATEBYMONTHDISC
        where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
          and LOWDATE <= @vBeginDate and HIGHDATE > @vBeginDate
        set @vBegITEMNO = ISNULL(@vBegITEMNO, 1)
        --取得结束统计区间
        select @vEndITEMNO = ITEMNO - 1 from CTCNTRRATEBYMONTHDISC
        where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
          and LOWDATE <= @vEndDate and HIGHDATE > @vEndDate
        set @vEndITEMNO = ISNULL(@vEndITEMNO, 1)
        --if @vEndITEMNO = 0 set @vEndITEMNO = 1

        set @vBaseTotal2 = 0

        --根据统计区间循环
        if object_id('c_DisByMonth') is not null deallocate c_DisByMonth
        declare c_DisByMonth cursor for
          select LOWDATE, HIGHDATE - 1, GAMT, RATE from CTCNTRRATEBYMONTHDISC
          where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
            and ITEMNO >= @vBegITEMNO and ITEMNO <= @vEndITEMNO
          order by LOWDATE
        open c_DisByMonth
        fetch next from c_DisByMonth into @vLOWDATE, @vHIGHDATE, @vGAMT, @vRateByMonth
        while @@fetch_status = 0
        begin
          set @vBaseTotal = 0
          if object_id('c_DataSrc') is not null deallocate c_DataSrc
          if exists (select 1 from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine)
            declare c_DataSrc cursor for
              select DSCODE from CTCNTRDTLDATASRC(nolock) where num = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
          else
            declare c_DataSrc cursor for
              select DSCODE from CTCHGDATASRC(nolock) where CODE = @vChgCode
          open c_DataSrc
          fetch next from c_DataSrc into @vDataSrc
          while @@fetch_status = 0
          begin
            set @vDataSrc = '0' + substring(@vDataSrc, 2, 3)
            exec @vRet = PCT_CHGBOOK_CALC_BASETOTAL @piCntrNum, @piCntrVersion, @piCntrLine, @vDataSrc,
              @vLOWDATE, @vHIGHDATE, @vTotal output, @poErrMsg output
            if @vRet <> 0 break
            set @vBaseTotal = @vBaseTotal + @vTotal

            fetch next from c_DataSrc into @vDataSrc
          end
          close c_DataSrc
          deallocate c_DataSrc
          if @vRet <> 0 break
          --如果CTCNTRRATEDTL.Case=1,那么使用定制的算法计算提成,否则保持原有逻辑
          if @vCase = 0
          begin
	          --将统计基数和保底金额比较
	          if @vBaseTotal >= @vGAMT set @vTmpRateTotal = 0
	          else set @vTmpRateTotal = (@vGAMT - @vBaseTotal) * @vRateByMonth / 100
	          set @vRateTotal = @vRateTotal + @vTmpRateTotal
	          if @vBaseTotal < @vGAMT set @vBaseTotal2 = @vBaseTotal2 + @vGAMT - @vBaseTotal
	        end
	        /*else begin
              --项目定制,计算提成
              --月租金-销售毛利
            end*/

          fetch next from c_DisByMonth into @vLOWDATE, @vHIGHDATE, @vGAMT, @vRateByMonth
        end
        close c_DisByMonth
        deallocate c_DisByMonth
        --set @vBaseTotal = isnull(@vBaseTotal, 0)
        set @vBaseTotal2 = isnull(@vBaseTotal2, 0)
        set @vBaseTotal = @vBaseTotal2

        if @vRateTotal < 0
        begin
          set @vRateTotal = -@vRateTotal
          set @vSign = -1
        end else
          set @vSign = 1

        --精度处理
        select @vRoundType = ROUNDTYPE, @vFeePrec = FEEPREC
        from CTCNTRRATEDTL where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

        if @vRoundType = '四舍五入'
          set @vRateTotal = floor((@vRateTotal / @vFeePrec) + 0.5) * @vFeePrec
        else if @vRoundType = '进一'
          set @vRateTotal = ceiling(@vRateTotal / @vFeePrec) * @vFeePrec
        else if @vRoundType = '去尾'
          set @vRateTotal = floor(@vRateTotal / @vFeePrec) * @vFeePrec

        set @vRateTotal = @vSign * @vRateTotal
        select @vCalcRate = Max(RATE)
        from CTCNTRRATEBYMONTHDISC where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
      end

      --创建费用单
      exec PCT_CHGBOOK_LOGRATERPT @piCntrNum, @piCntrVersion, @vChgCode, @vDate, @piGenDate, @vBeginDate, @vEndDate, @vBaseTotal, @vRateTotal
      exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK null, @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @piGenDate, @vBeginDate, @vEndDate,
        @vBaseTotal, @vRateTotal, @vCalcRate, null, @piGenDate, @vDate, null, @vChgBookNum output, @piOperGid, @poErrMsg output
      if @vRet <> 0 break
    end

    if @vDefCycle = 0
    begin
      --更新下次统计日期
      exec @vRet = PCT_CHGBOOK_UPDATE_NEXT_CYCLE @piCntrNum, @piCntrVersion, @piCntrLine, @poErrMsg output
      if @vRet <> 0 return(@vRet)
    end else break
  end

  return(0)
end
GO
