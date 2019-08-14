SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_UPDATERULE]
(
  @piNum char(14),
  @poErrMsg varchar(255) output
) as
begin
  declare @vRCode varchar(20)
  declare @vGroupID int
  declare @vCostPrc money
  declare @vGftGid int
  declare @vQty money

  exec HDDEALLOCCURSOR 'c_gftsnd' --确保游标被释放
  declare c_gftsnd cursor for
  select RCODE, GROUPID, GFTGID, QTY, COSTPRC from GFTPRMSNDGIFT
  where NUM = @piNum
  open c_gftsnd
  fetch next from c_gftsnd into @vRCode, @vGroupID, @vGftGid, @vQty, @vCostPrc
  while @@fetch_status = 0
  begin
    update GFTPRMGIFTDTL set SUMQTY = SUMQTY + @vQty
    where RCODE = @vRCode and GROUPID = @vGroupID and GFTGID = @vGftGid
    update GFTPRMGIFT set SUMAMT = SUMAMT + @vCostPrc * @vQty
    where RCODE = @vRCode and GROUPID = @vGroupID

    fetch next from c_gftsnd into @vRCode, @vGroupID, @vGftGid, @vQty, @vCostPrc
  end
  close c_gftsnd
  deallocate c_gftsnd
  return(0)
end
GO
