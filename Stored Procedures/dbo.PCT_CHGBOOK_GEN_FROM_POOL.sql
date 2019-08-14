SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [dbo].[PCT_CHGBOOK_GEN_FROM_POOL] (
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vRet integer
  declare @vChgBookNum varchar(14)
  declare @vSysDate datetime
  declare @vVdrGid integer
  declare @vChgCode varchar(20)
  declare @vCntrNum varchar(14)
  declare @vCalcBegin datetime
  declare @vCalcEnd datetime
  declare @vCalcTotal decimal(24, 2)
  declare @vSrcNum varchar(20)
  declare @vSrcCls varchar(20)
  declare @vGatheringMode varchar(20)
  declare @vPayDirect integer
  declare @vDept varchar(20)
  declare @vPsr varchar(20)
  declare @vPsrGid integer
  declare @NOTE varchar(255)
  --若干与费用单有关的选项
  declare
    @v_OptDeptLmt Int, --结算是否采用费用结算组限制
    @v_OptDeptVdrLmt Int, --2=按费用结算组与供应商对照关系取值
    @v_StrSql Varchar(1000) --动态Sql语句

  Exec OPTREADINT 0, 'SettleDeptLimit', 1, @v_OptDeptLmt OUTPUT
  Exec OPTREADINT 0, 'AutoGetSettleDeptMethod', 1, @v_OptDeptVdrLmt OUTPUT

  if object_id('c_Pool') is not null deallocate c_Pool
  declare c_Pool cursor for
    select VDRGID, CHGCODE, CNTRNUM, CALCBEGIN, CALCEND,
      CALCTOTAL, SRCNUM, SRCCLS, GATHERINGMODE, PAYDIRECT,
      DEPT, PSR,NOTE
    from TMPCHGBOOK where SPID = @@spid

  select @vSysDate = convert(varchar, getdate(), 102)

  delete from TMPGENBILLS where OWNER = '生成费用单' and SPID = @@spid
  open c_Pool
  fetch next from c_Pool into @vVdrGid, @vChgCode, @vCntrNum, @vCalcBegin, @vCalcEnd,
    @vCalcTotal, @vSrcNum, @vSrcCls, @vGatheringMode, @vPayDirect, @vDept, @vPsr ,@NOTE
  while @@fetch_status = 0
  begin
    --结算组合法性检查
    If @vDept <> ''
    Begin
      Set @v_StrSql = ''
      if object_id('tempdb..#tmpde') is not null drop table #tmpde
      Set @v_StrSql = @v_StrSql + ' Select SettleDept.Code Into #tmpde From SettleDept, SettleDeptEmp '
        + ' where SettleDept.Code = ''' + @vDept + ''''
        + '   and settledept.code = settledeptemp.code and settleDeptEmp.empGid = ' + Str(@piOperGid)
      If (@v_OptDeptLmt = 1) and ( (@v_OptDeptVdrLmt = 2) or (@v_OptDeptVdrLmt = 5) )
        Set @v_StrSql = @v_StrSql + ' and Exists(Select 1 from settledeptvdr vdr '
          + ' Where vdr.code = SettleDept.Code and vdr.vdrgid = ' + Str(@vVdrGid) + ')'
      Set @v_StrSql = @v_StrSql + ' Delete from #tmpde '
      Exec(@v_StrSql)
      If @@Rowcount = 0
      Begin
        set @poErrMsg = '存在结算组不满足条件：' + @vDept
        close c_Pool
        deallocate c_Pool
        return(1)
      End
    End
    --采购员合法性检查
    set @vPsrGid = 0
    if rtrim(isnull(@vPsr, '')) <> ''
    begin
      select @vPsrGid = GID from EMPLOYEE where CODE = @vPsr
      if @@rowcount = 0
      begin
        set @poErrMsg = '未找到采购员 ' + @vPsr
        close c_Pool
        deallocate c_Pool
        return(1)
      end
      --结算采用费用结算组限制时增加判断
      If (@v_OptDeptLmt = 1) And (@vDept <> '')
      Begin
        If Not Exists (Select 1 from Employee Where (Code = @vPsr)
            And Gid in (Select EmpGid from SettleDeptEmp Where Code = @vDept))
        Begin
          set @poErrMsg = '采购员不属于对应结算组:' + @vPsr
          close c_Pool
          deallocate c_Pool
          return(1)
        End
      End
    end
    --检查账款项目是否存在
    If not Exists(Select 1 From CtChgdef Where Code = @vChgCode)
    Begin
      set @poErrMsg = '未找到账款项目 ' + @vChgCode
      close c_Pool
      deallocate c_Pool
      return(1)
    End

    set @NOTE= '外部导入' + SUBSTRING(@Note, 1, 246)
    exec @vRet = PCT_CHGBOOK_FILL @vVdrGid, @vCntrNum, @vChgCode, @vCalcBegin, @vCalcEnd,
      @vCalcTotal, @vSysDate, @vSysDate, @vGatheringMode, @vPayDirect,
      @vDept, @vPsrGid,@NOTE, @vSrcCls, @vSrcNum,
      @piOperGid, @vChgBookNum output, @poErrMsg output
    if @vRet <> 0
    begin
      close c_Pool
      deallocate c_Pool
      return(@vRet)
    end
    --记录到临时表
    insert into TMPGENBILLS(SPID, OWNER, BILLNAME, NUM, DTLCNT, STARTTIME, FINISHTIME, STAT)
    values(@@spid, '生成费用单', '费用单', @vChgBookNum, 0, getdate(), getdate(), 0)

    fetch next from c_Pool into @vVdrGid, @vChgCode, @vCntrNum, @vCalcBegin, @vCalcEnd,
      @vCalcTotal, @vSrcNum, @vSrcCls, @vGatheringMode, @vPayDirect, @vDept, @vPsr,@NOTE
  end
  close c_Pool
  deallocate c_Pool

  return(0)
end
GO
