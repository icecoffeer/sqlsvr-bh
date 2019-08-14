SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_FreshStkin_GetGoods](
  @piVdrCode varchar(10),
  @piWrhCode varchar(10),
  @piDeptCode varchar(10),
  @piTaxRateLmt decimal(24,4),
  @piNote varchar(255),
  @piInputGdCode varchar(40),
  @poGdCode varchar(13) output,
  @poGdName varchar(50) output,
  @poGdSpec varchar(40) output,
  @poGdMUnit varchar(6) output,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int

  --检查货品的合法性。
  set @return_status = 0
  if exists(select 1 from SYSTEM(nolock) where USERGID = ZBGID)
  begin
    exec @return_status = RFIntfForHD_FreshStkin_ChkGoods_Stkin @piVdrCode,
      @piWrhCode, @piDeptCode, @piTaxRateLmt, @piNote, @piInputGdCode,
      @poErrMsg output
  end
  else begin
    exec @return_status = RFIntfForHD_FreshStkin_ChkGoods_Dirin @piVdrCode,
      @piWrhCode, @piDeptCode, @piTaxRateLmt, @piNote, @piInputGdCode,
      @poErrMsg output
  end
  if @return_status <> 0
    return 1

  --读取货品信息。
  select
    @poGdCode = rtrim(g.CODE),
    @poGdName = rtrim(g.NAME),
    @poGdSpec = '1*' + convert(varchar, g.QPC),
    @poGdMUnit = rtrim(g.MUNIT)
    from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
    and gi.CODE = @piInputGdCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '货品' + rtrim(@piInputGdCode) + '无效。'
    return 1
  end

  return 0
end
GO
