SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_FreshStkin_ChkGoods_Dirin](
  @piVdrCode varchar(10),
  @piWrhCode varchar(10),
  @piDeptCode varchar(10),
  @piTaxRateLmt decimal(24,4),
  @piNote varchar(255),
  @piInputGdCode varchar(40),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @RstWrh int,
    @SingleVdr int,
    @UserGid int,
    @ZBGid int,
    @VdrGid int,
    @WrhGid int,
    @GdGid int,
    @GdIsLtd int,
    @GdF1 varchar(64),
    @GdTaxRate decimal(24,4),
    @GdSale int,
    @GdAlc char(10),
    @Opt_AlcLmt int,
    @Opt_DeptLmtLen int,
    @Opt_ResInvOperByGDSale int,
    @Opt_VdrGd2Lmt int,
    @Opt_MstInputDept int,
    @Opt_MstInputTaxRateLmt int

  --获取系统设定的值。
  select @RstWrh = RSTWRH,
    @SingleVdr = SINGLEVDR,
    @UserGid = USERGID,
    @ZBGid = ZBGID
    from SYSTEM(nolock)

  --读取选项的值。
  exec OPTREADINT 0, 'AlcLmt', 0, @Opt_AlcLmt output
  exec OPTREADINT 0, 'PS3_DepLmtLen', 0, @Opt_DeptLmtLen output
  exec OPTREADINT 0, 'ResInvOperByGDSale', 0, @Opt_ResInvOperByGDSale output
  exec OPTREADINT 0, 'VdrGd2Lmt', 0, @Opt_VdrGd2Lmt output
  exec OPTREADINT 84, 'MstInputDept', 0, @Opt_MstInputDept output
  exec OPTREADINT 84, 'MstInputTaxRateLmt', 0, @Opt_MstInputTaxRateLmt output

  --检查传入参数的合法性。
  ----检查供应商代码。
  if rtrim(isnull(@piVdrCode, '')) = ''
  begin
    set @poErrMsg = '供应商代码不能为空。'
    return 1
  end
  select @VdrGid = GID from VENDOR(nolock) where CODE = @piVdrCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '供应商代码' + rtrim(@piVdrCode) + '无效。'
    return 1
  end
  ----检查仓位代码。
  if rtrim(isnull(@piWrhCode, '')) = ''
  begin
    set @poErrMsg = '仓位代码不能为空。'
    return 1
  end
  select @WrhGid = GID from WAREHOUSE(nolock) where CODE = @piWrhCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '仓位代码' + rtrim(@piWrhCode) + '无效。'
    return 1
  end
  ----检查部门代码。
  if @Opt_MstInputDept = 1
  begin
    if rtrim(isnull(@piDeptCode, '')) = ''
    begin
      set @poErrMsg = '部门代码不能为空。'
      return 1
    end
    else if not exists(select 1 from DEPT(nolock) where CODE = @piDeptCode)
    begin
      set @poErrMsg = '部门代码' + rtrim(@piDeptCode) + '无效。'
      return 1
    end
  end
  else if rtrim(isnull(@piDeptCode, '')) <> ''
  begin
    set @poErrMsg = '部门代码不能填写。'
    return 1
  end
  ----检查税率限制。
  if @Opt_MstInputTaxRateLmt = 1 and isnull(@piTaxRateLmt, 0) <= 0
  begin
    set @poErrMsg = '税率限制不能为空。'
    return 1
  end
  else if @Opt_MstInputTaxRateLmt = 0 and isnull(@piTaxRateLmt, 0) > 0
  begin
    set @poErrMsg = '税率限制不能填写。'
    return 1
  end
  ----检查备注。
  if rtrim(isnull(@piNote, '')) = ''
  begin
    set @poErrMsg = '备注不能为空。'
    return 1
  end
  ----检查货品码。
  if rtrim(isnull(@piInputGdCode, '')) = ''
  begin
    set @poErrMsg = '货品码不能为空。'
    return 1
  end
  select
    @GdGid = g.GID,
    @GdTaxRate = g.TAXRATE,
    @GdF1 = g.F1,
    @GdIsLtd = g.ISLTD,
    @GdSale = g.SALE,
    @GdAlc = g.ALC
    from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
    and gi.CODE = @piInputGdCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '货品码' + rtrim(@piInputGdCode) + '无效。'
    return 1
  end

  --检查货品属性。
  ----限制业务属性。
  if @GdIsLtd & 8 = 8
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '是清场品，不能录入。'
    return 1
  end
  else if @GdIsLtd & 2 = 2
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '是限制定货品，不能录入。'
    return 1
  end
  ----部门限制
  if @Opt_MstInputDept = 1 and rtrim(isnull(@piDeptCode, '')) <> ''
  begin
    set @piDeptCode = rtrim(isnull(@piDeptCode, ''))
    set @GdF1 = rtrim(isnull(@GdF1, ''))
    if @Opt_DeptLmtLen <> 0 and substring(@GdF1, 1, @Opt_DeptLmtLen) <> @piDeptCode
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '的部门代码不是' + @piDeptCode + '，不能录入。'
      return 1
    end
    else if @Opt_DeptLmtLen = 0 and @GdF1 <> @piDeptCode
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '的部门代码不是' + @piDeptCode + '，不能录入。'
      return 1
    end
  end
  ----税率限制
  if @Opt_MstInputTaxRateLmt = 1 and isnull(@piTaxRateLmt, 0) > 0 and @GdTaxRate <> @piTaxRateLmt
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '的税率不是' + convert(varchar, @piTaxRateLmt) + '，不能录入。'
    return 1
  end
  ----营销方式限制
  if @Opt_ResInvOperByGDSale in (1, 3) and @GdSale = 3
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '是联销商品，不能录入。'
    return 1
  end
  else if @Opt_ResInvOperByGDSale in (2, 3) and @GdSale = 2
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '是代销商品，不能录入。'
    return 1
  end
  ----配货方式限制
  if @Opt_AlcLmt = 1 and rtrim(@GdAlc) <> '直配'
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '的配货方式不是直配，不能录入。'
    return 1
  end

  --检查仓位部门限制及一品多供应商限制。
  if @RstWrh = 0 --无部门或仓位限制
  begin
    if @SingleVdr = 1 and not exists(select 1 from GOODS(nolock)
      where GID = @GdGid
      and BILLTO = @VdrGid) --一品单供应商
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '的缺省供应商不是' + rtrim(@piVdrCode) + '，不能录入。'
      return 1
    end
    else if @SingleVdr = 2 and @Opt_VdrGd2Lmt = 1 and not exists(select 1
      from VDRGD2 vg2(nolock)
      where vg2.GDGID = @GdGid
      and vg2.STOREGID = @UserGid
      and vg2.VDRGID = @VdrGid) --一品多供应商
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '不在VDRGD2中。'
      return 1
    end
  end
  else if @RstWrh = 1 --仓位限制
  begin
    if not exists(select 1 from VDRGD vg(nolock)
      where vg.GDGID = @GdGid
      and vg.VDRGID = @ZBGid
      and vg.WRH = @WrhGid)
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '不在VDRGD中。'
      return 1
    end
  end
  else if @RstWrh = 2 --部门限制
  begin
    if not exists(select 1 from V_GOODS(nolock) where GID = @GdGid)
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '不在V_GOODS中。'
      return 1
    end
    else if @SingleVdr = 1 and not exists(select 1 from V_GOODS(nolock)
      where GID = @GdGid
      and BILLTO = @VdrGid) --一品单供应商
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '的缺省供应商不是' + rtrim(@piVdrCode) + '，不能录入。'
      return 1
    end
    else if @SingleVdr = 2 and @Opt_VdrGd2Lmt = 1 and not exists(select 1
      from VDRGD2 vg2(nolock)
      where vg2.GDGID = @GdGid
      and vg2.STOREGID = @UserGid
      and vg2.VDRGID = @VdrGid) --一品多供应商
    begin
      set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '不在VDRGD2中。'
      return 1
    end
  end

  return 0
end
GO
