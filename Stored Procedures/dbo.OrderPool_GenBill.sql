SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_GenBill](
  @piGoodsCond varchar(1000),
  @piOperGid int,
  @piType int, --1：定货，2：叫货申请
  @piCaller varchar(255), --调用方信息。'HDPOS'-pos客户端调用；'RF'-rf客户端调用
  @poErrMsg varchar(255) output
)
as
begin
  declare @vRet int
  declare @vInUse int
  declare @vOper varchar(30)

  --检查并发操作
  exec OptReadInt 8183, 'InUse', 0, @vInUse output
  if @vInUse <> 0
  begin
    if @piCaller = 'HDPOS'
    begin
      --客户端调用时只要有人在生成就不允许操作
      set @poErrMsg = '当前有其他用户正在从定货池生成单据，禁止重复操作'
      return 1
    end
    else if @piCaller = 'RF' and @vInUse = @piOperGid
    begin
      --RF调用时需判断是否同一人在操作，同一人允许操作
      set @poErrMsg = '当前有其他用户正在从定货池生成单据，禁止重复操作'
      return 1
    end
  end

  --修改生成标记，表示开始执行操作
  update HDOPTION set OPTIONVALUE = @piOperGid
    where MODULENO = 8183 and OPTIONCAPTION = 'InUse'

  --用户名代码
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
    from EMPLOYEE(nolock)
    where GID = @piOperGid

  --RF客户端调用
  if @piCaller = 'RF'
  begin
    --只影响操作用户上传的数据
    if rtrim(isnull(@piGoodsCond, '')) = ''
      set @piGoodsCond = ' ORDERPOOL.IMPORTER = ''' + @vOper + ''''
    else
      set @piGoodsCond = @piGoodsCond + ' and ORDERPOOL.IMPORTER = ''' + @vOper + ''''

    --清空缓存
    if exists(select * from ORDERPOOLGENBILLS where FLAG in (1, 2))
    begin
      exec @vRet = OrderPool_GenBillRollback @piOperGid, @poErrMsg output
      if @vRet <> 0
      begin
        --修改生成标记
        update HDOPTION set OPTIONVALUE = 0
          where MODULENO = 8183 and OPTIONCAPTION = 'InUse'
        return @vRet
      end
    end

    delete from ORDERPOOLGENBILLS where FLAG > 2
  end

  --生成定货单，ORDERPOOL.ORDERTYPE <> 'RF叫货申请'
  if @piType & 1 = 1
  begin
    exec @vRet = OrderPool_GenBill_Ord
      @piGoodsCond,
      @piOperGid,
      @piCaller,
      @poErrMsg output
    if @vRet <> 0
    begin
      --修改生成标记
      update HDOPTION set OPTIONVALUE = 0
        where MODULENO = 8183 and OPTIONCAPTION = 'InUse'
      return @vRet
    end
  end

  --生成门店叫货申请单，ORDERPOOL.ORDERTYPE = 'RF叫货申请'
  if @piType & 2 = 2
  begin
    exec @vRet = OrderPool_GenBill_OrdApply
      @piGoodsCond,
      @piOperGid,
      @piCaller,
      @poErrMsg output
    if @vRet <> 0
    begin
      --修改生成标记
      update HDOPTION set OPTIONVALUE = 0
        where MODULENO = 8183 and OPTIONCAPTION = 'InUse'
      return @vRet
    end
  end

  --如果是RF端调用，则改变单据状态
  if @piCaller = 'RF'
  begin
    exec @vRet = OrderPool_CheckBill @piOperGid, @poErrMsg output
    if @vRet <> 0
    begin
      --修改生成标记
      update HDOPTION set OPTIONVALUE = 0
        where MODULENO = 8183 and OPTIONCAPTION = 'InUse'
      return @vRet
    end
  end

  --恢复生成标记为0
  update HDOPTION set OPTIONVALUE = 0
    where MODULENO = 8183 and OPTIONCAPTION = 'InUse'

  return 0
end
GO
