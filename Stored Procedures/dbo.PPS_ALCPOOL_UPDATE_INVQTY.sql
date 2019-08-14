SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_UPDATE_INVQTY]
as
begin
  declare @vUserGid int
  select @vUserGid = USERGID from SYSTEM(nolock)
  --计算当前库存数
  update alcpooltemp
    set invqty = (select isnull(sum(AVLQTY), 0)
    from V_ALCINV(nolock)
    where store = @vUserGid
      and gdgid = alcpooltemp.gdgid)
  return(0);
end
GO
