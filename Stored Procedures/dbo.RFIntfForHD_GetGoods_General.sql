SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetGoods_General](
  @piBarCode varchar(40),       --条码
  @poGdGid int output,          --商品内码
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare @return_status smallint

  set @return_status = 1

  if exists(select * from GDINPUT(nolock) where CODE = @piBarCode)
  begin
    select @poGdGid = g.GID
      from GDINPUT gi(nolock), GOODS g(nolock)
      where gi.GID = g.GID
      and gi.CODE = @piBarCode

    set @return_status = 0
  end

  return @return_status
end
GO
