SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GftPrmBck_RetOne]
(
  @piCls	varchar(10),--no use now
  @piPosNo	varchar(10),
  @piFlowNo	varchar(14),
  @piGDGid	int,
  @piBckQty	money,
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @ret int
  set @ret = 0
  update tmpgftsndsale set
    qty = qty - @piBckQty, amt = amt*((qty-@piBckQty)/(qty*1.0))
    where spid = @@spid and gdgid = @piGDGid
      and posno = @piPosNo and FlowNo = @piFlowNo
  return @ret
end
GO
