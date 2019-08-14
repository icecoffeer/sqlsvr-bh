SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alloc_ChkGoods](
  @piEmpCode varchar(10),        --传入参数：操作员代码。
  @piClientCode varchar(10),     --传入参数：配往单位代码，对应于STORE.CODE。
  @piWrhCode varchar(10),        --传入参数：仓位代码，对应于WAREHOUSE.CODE。
  @piInputGdCode varchar(40),    --传入参数：货品码（代码、输入码）。
  @poErrMsg varchar(255) output  --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @return_status int,
    @RstWrh int,
    @ClientName varchar(50),
    @ClientGid int,
    @WrhName varchar(50),
    @WrhGid int,
    @GdGid int,
    @GdIsLtd int,
    @GsIsLtd int

  --读取系统设定的值。
  select @RstWrh = RSTWRH from SYSTEM(nolock)

  --校验配往单位代码的合法性。
  exec @return_status = RFIntfForHD_Alloc_GetClientName @piClientCode,
    @ClientName output, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取配往单位GID。此处必然存在一条记录。
  select @ClientGid = GID
    from STORE(nolock)
    where CODE = @piClientCode

  --校验仓位代码的合法性。
  exec @return_status = RFIntfForHD_GetWarehouseName @piEmpCode, @piWrhCode,
    @WrhName output, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取仓位GID。此处必然存在一条记录。
  select @WrhGid = GID
    from WAREHOUSE(nolock)
    where CODE = @piWrhCode

  --检查货品码是否为空。
  if @piInputGdCode is null or rtrim(@piInputGdCode) = ''
  begin
    set @poErrMsg = '货品码不能为空。'
    return 1
  end

  --检查货品码是否在商品表中。
  if not exists(select 1 from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
    and gi.CODE = @piInputGdCode)
  begin
    set @poErrMsg = '货品码不在商品表中。'
    return 1
  end

  --从商品表中获取货品信息。此处必然存在一条记录。
  select
    @GdGid = g.GID,
    @GdIsLtd = isnull(g.ISLTD, 0)
    from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
    and gi.CODE = @piInputGdCode

  --检查货品在配自单位是否被限制配货。
  if @GdIsLtd & 1 = 1
  begin
    set @poErrMsg = '货品 ' + rtrim(@piInputGdCode) + ' 在配自单位被限制配货，不能录入。'
    return 1
  end
  --检查货品在配自单位是否清场品。
  if @GdIsLtd & 8 = 8
  begin
    set @poErrMsg = '货品 ' + rtrim(@piInputGdCode) + ' 在配自单位是清场品，不能录入。'
    return 1
  end

  --从各店商品表中获取货品信息。此处未必存在记录。
  select
    @GsIsLtd = isnull(gs.ISLTD, 0)
    from GDSTORE gs(nolock)
    where gs.GDGID = @GdGid
    and gs.STOREGID = @ClientGid
  if @GsIsLtd is null
    set @GsIsLtd = 0
  --检查货品在配往单位是否被限制配货。
  if @GsIsLtd & 1 = 1
  begin
    set @poErrMsg = '货品 ' + rtrim(@piInputGdCode) + ' 在配往单位被限制配货，不能录入。'
    return 1
  end

  --检查仓位限制条件。
  if @RstWrh = 1 and not exists(select 1 from VDRGD(nolock)
    where GDGID = @GdGid
    and WRH = @WrhGid)
  begin
    set @poErrMsg = '货品 ' + rtrim(@piInputGdCode) + ' 不在VDRGD表中，不能录入。'
    return 1
  end

  --检查部门限制条件（暂不支持）。
  if @RstWrh = 2
  begin
    set @poErrMsg = '暂不支持部门限制。请先在后台录入配出单，并请信息部来解决该问题。'
    return 1
  end

  return 0
end
GO
