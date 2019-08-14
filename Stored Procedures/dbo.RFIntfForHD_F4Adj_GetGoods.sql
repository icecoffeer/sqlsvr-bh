SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_F4Adj_GetGoods](
  @piBarCode varchar(40),
  @poGdCode varchar(13) output,
  @poGdName varchar(50) output,
  @poSpec varchar(40) output,
  @poLowInv decimal(24,4) output,
  @poHighInv decimal(24,4) output,
  @poF4 varchar(50) output,
  @poErrMsg varchar(255) output
)
as
begin
  --获取商品信息

  select @poGdCode = g.CODE,
    @poGdName = g.NAME,
    @poSpec = g.SPEC,
    @poLowInv = g.LOWINV,
    @poHighInv = g.HIGHINV,
    @poF4 = g.F4
    from GOODS g(nolock), GDINPUT gi(nolock)
    where g.GID = gi.GID
      and gi.CODE = @piBarCode

  return 0
end
GO
