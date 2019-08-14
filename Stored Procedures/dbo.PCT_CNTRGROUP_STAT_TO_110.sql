SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_STAT_TO_110](
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  if exists(select 1 from GROUPCNTR gc(nolock), CTCNTR c(nolock)
    where gc.NUM = @piNum 
      and gc.VERSION = @piVersion
      and gc.CNTRNUM = c.NUM
      and gc.CNTRVERSION = c.VERSION
      and c.TAG = 1
      and c.STAT in (500, 1600))
  begin
    set @poErrMsg = '合约组存在已预审或已审核的合约，不能作废';
    return(1);
  end;
  update CNTRGROUP set stat = 110, realenddate = getdate()
  where NUM = @piNum and VERSION = @piVersion;
  return(0);
end;
GO
