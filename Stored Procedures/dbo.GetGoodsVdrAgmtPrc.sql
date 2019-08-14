SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsVdrAgmtPrc](
  @piGdGid int,
  @piVdrGid int,
  @poVdrAgmtPrc decimal(24,4) output
)
with encryption
as
begin
  select @poVdrAgmtPrc = PRICE
    from VDRAGMTINV Mst(nolock), VDRAGMTDTLINV Dtl(nolock)
    where Mst.NUM = Dtl.NUM
      and Mst.VDRGID = @piVdrGid
      and Mst.STARTDATE <= convert(varchar(10), GetDate(), 102)
      and Mst.FINISHDATE >= convert(varchar(10), GetDate(), 102)
      and Dtl.GDGID = @piGdGid
  if @poVdrAgmtPrc is not null
  	return 0
  else
  	return 1
end
GO
