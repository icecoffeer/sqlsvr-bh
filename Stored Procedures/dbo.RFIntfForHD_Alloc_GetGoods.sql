SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alloc_GetGoods](
  @piEmpCode varchar(10),                  --传入参数：操作员代码。
  @piClientCode varchar(10),               --传入参数：配往单位代码，对应于STORE.CODE。
  @piWrhCode varchar(10),                  --传入参数：仓位代码，对应于WAREHOUSE.CODE。
  @piInputGdCode varchar(40),              --传入参数：货品码（代码、输入码）。
  @poGdCode varchar(13) output,            --传出参数（返回值为0时有效）：货品代码（GOODS.CODE）。
  @poGdName varchar(50) output,            --传出参数（返回值为0时有效）：货品名称（GOODS.NAME）。
  @poGdQpc decimal(24,4) output,           --传出参数（返回值为0时有效）：货品包装规格（GOODS.QPC）。
  @poGdMUnit varchar(6) output,            --传出参数（返回值为0时有效）：货品计量单位（GOODS.MUNIT）。
  @poPrice decimal(24,4) output,           --传出参数（返回值为0时有效）：系统默认的配出单价。
  @poErrMsg varchar(255) output            --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @return_status int,
    @ClientGid int,
    @WrhGid int,
    @GdGid int

  --检查传入参数。
  exec @return_status = RFIntfForHD_Alloc_ChkGoods @piEmpCode, @piClientCode,
    @piWrhCode, @piInputGdCode, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取配往单位GID。此处必然存在一条记录。
  select @ClientGid = GID
    from STORE(nolock)
    where CODE = @piClientCode

  --获取仓位GID。此处必然存在一条记录。
  select @WrhGid = GID
    from WAREHOUSE(nolock)
    where CODE = @piWrhCode

  --获取货品信息。此处必然存在一条记录。
  select
    @GdGid = g.GID,
    @poGdCode = rtrim(g.CODE),
    @poGdName = rtrim(g.NAME),
    @poGdQpc = g.QPC,
    @poGdMUnit = rtrim(g.MUNIT)
    from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
    and gi.CODE = @piInputGdCode

  --获取货品的系统默认单价。
  exec @return_status = GetStoreOutPrc @ClientGid, @GdGid, @WrhGid, @poPrice output

  return 0
end
GO
