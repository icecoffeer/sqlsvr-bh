SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_REMOVE]
(
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vVersion int
  declare @vStat int

  --数据检查
  exec PCT_CNTR_CURRENT_VERSION @piNum, @vVersion output
  if(@vVersion <> @piVersion)
  begin
    set @poErrMsg = '不能处理历史合约.';
    return(1);
  end;
  select @vStat = STAT from CTCNTR(nolock) where NUM = @piNUM and VERSION = @piVersion;
  if (@vStat <> 0)
  begin
    set @poErrMsg = '合约' + @piNum + '版本(' + rtrim(convert(varchar, @piVersion)) + ')不是未审核状态，不允许删除.';
    return(1);
  end;

  delete from CTCNTR where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRDTL where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRFIXDTL where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRFIXDATE where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRFIXSTORE where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATEDTL where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATEDISC where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATEBYMONTHDISC where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATEBYMONTHSTOREGDDISC where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATESTORE where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATEGOODS where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATESTOREGD where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATESTOREGDDISC where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRRATEGUARDCHG where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRDTLDATASRC where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRLOG where NUM = @piNum and VERSION = @piVersion;
  delete from GROUPCNTR where CNTRNUM = @piNum and CNTRVERSION = @piVersion;
  delete from CTCNTRRATECONDPLAN where NUM = @piNum and VERSION = @piVersion;--zz 090508
  delete from CTCNTRBRAND where NUM = @piNum and VERSION = @piVersion;
  delete from CTCNTRBRANDKWHMETER where NUM = @piNum and VERSION = @piVersion;

  return(0);
end
GO
