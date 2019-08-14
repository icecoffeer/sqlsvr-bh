SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvLossMore_GetGoods](
  @piBarCode char(40),
  @poGdCode char(13) output,
  @poGdName char(50) output,
  @poSpec char(40) output,
  @poMUnit char(6) output,
  @poErrMsg varchar(255) output
)
as
begin
  select @poGdCode = g.CODE,
    @poGdName = g.NAME,
    @poSpec = g.SPEC,
    @poMUnit = g.MUNIT
    from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
      and gi.CODE = @piBarCode

  if @@rowcount = 0
  begin
    set @poErrMsg = '该商品条码无效'
    return 1
  end

  return 0
end
GO
