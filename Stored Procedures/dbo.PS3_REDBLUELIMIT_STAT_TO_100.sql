SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_STAT_TO_100]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  declare @vVendor int,
          @vGdGid int, 
          @vLimitPercent money,
          @vLimitTotal money,
          @vStoreGid int,
          @vRet int,
          @vLine int

  if object_id('c_RedBlue100') is not null deallocate c_RedBlue100
  declare c_RedBlue100 cursor for
    select A.VENDOR, B.GDGID, B.LIMITPERCENT, B.LIMITTOTAL, C.STOREGID from PS3REDBLUECARD A, 
       PS3REDBLUECARDDTL B, PS3REDBLUECARDSTOREDTL C 
      where A.NUM = @piNum and A.NUM = B.NUM and A.NUM = C.NUM  
  set @vLine = 1    
  open c_RedBlue100
  fetch next from c_RedBlue100 into @vVendor, @vGdGid, @vLimitPercent, @vLimitTotal, @vStoreGid
  while @@fetch_status = 0 
  begin
    select @vRet = count(1) from BLUECARDLIMITEFFECT(nolock) where VENDOR = @vVendor and STORE = @vStoreGid and GDGID = @vGdGid
    if @vRet > 0 
      delete from BLUECARDLIMITEFFECT where VENDOR = @vVendor and STORE = @vStoreGid and GDGID = @vGdGid
    insert into BLUECARDLIMITEFFECT(NUM, LINE, GDGID, STORE, VENDOR, REDCARDLIMITPERCENT, BLUECARDLIMITTOTAL)
      values(@piNum, @vLine, @vGdGid, @vStoreGid, @vVendor, @vLimitPercent, @vLimitTotal)
    set @vLine = @vLine + 1
    fetch next from c_RedBlue100 into @vVendor, @vGdGid, @vLimitPercent, @vLimitTotal, @vStoreGid
  end 
  close c_RedBlue100
  deallocate c_RedBlue100  
  update PS3REDBLUECARD set STAT = 100, CHECKER = @piOper, CHKDATE = getdate() where NUM = @piNum
  exec PS3_REDBLUELIMIT_ADD_LOG @piNum, 0, 100, @piOper
  return 0
end
GO
