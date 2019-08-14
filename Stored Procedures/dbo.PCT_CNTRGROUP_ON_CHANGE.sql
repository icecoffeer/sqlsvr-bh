SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_ON_CHANGE]
(
  @piNum	char(14),
  @piOldVersion	int,
  @piNewVersion	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vRet int
  declare @vEndDate datetime
  declare @vCntrNum char(14)
  declare @vCntrEndDate datetime

  select @vEndDate = ENDDATE from CNTRGROUP where NUM = @piNum and VERSION = @piNewVersion;

  --检查合约组截止日期不能小于子合约的截止日期
  if object_id('c_CNTR') is not null deallocate c_CNTR
  declare c_CNTR cursor for
  select c.NUM, c.ENDDATE from CTCNTR c, GROUPCNTR gc
  where c.NUM = gc.CNTRNUM
    and c.VERSION = gc.CNTRVERSION
    and gc.NUM = @piNum
    and gc.VERSION = @piOldVersion
    and c.TAG = 1;
  open c_CNTR
  fetch next from c_CNTR into @vCntrNum, @vCntrEndDate
  while @@fetch_status = 0
  begin
    if(@vCntrEndDate > @vEndDate)
    begin
      set @poErrMsg = '合约组的截止日期小于子合约' + rtrim(@vCntrNum) + '的截止日期：' + convert(varchar(10), @vCntrEndDate, 102);
      close c_CNTR;
      deallocate c_CNTR;
      return(1);
    end;
    fetch next from c_CNTR into @vCntrNum, @vCntrEndDate
  end;
  close c_CNTR;
  deallocate c_CNTR;

  --复制合约组-子合约关系
  insert into GROUPCNTR(NUM, VERSION, CNTRNUM, CNTRVERSION)
  select @piNum, @piNewVersion, CNTRNUM, CNTRVERSION
  from GROUPCNTR
  where NUM = @piNum and VERSION = @piOldVersion;
  --修改

  update CNTRGROUP set STAT = 100 where NUM = @piNum and VERSION = @piNewVersion;

  exec @vRet = PCT_CNTRGROUP_INTERNAL_MODIFY @piNum, @piOldVersion, @piOperGid, @poErrMsg output
  if(@vRet <> 0) return(@vRet);
  exec @vRet = PCT_CNTRGROUP_INTERNAL_MODIFY @piNum, @piNewVersion, @piOperGid, @poErrMsg output
  if(@vRet <> 0) return(@vRet);
  return(0);  
end
GO
