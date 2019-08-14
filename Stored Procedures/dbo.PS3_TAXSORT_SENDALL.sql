SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_TAXSORT_SENDALL]
(
  @piRcvGid int,            --接收门店
  @piFrcUpd int,            --是否强制更新
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vID int,
    @vGid int,
    @vUserGid int

  --取得system.usergid
  select @vUserGid = USERGID from FASYSTEM(nolock)

  delete from NTAXSORT where TYPE = 0 and RCV = @piRcvGid

  declare curNTaxSort cursor for
    select GID from TaxSort(nolock)
  open curNTaxSort
  fetch next from curNTaxSort into @vGid
  while @@fetch_status = 0
  begin
    execute GetNetBillId @vID output
    
    insert into NTaxSort (SRC, ID, GID, CODE, NAME, PROVINCE, RCV, FRCUPD, TYPE, NSTAT)
    select @vUserGid, @vID, GID, Code, Name, Province, @piRcvGid, @piFrcUpd, 0, 0
        from TaxSort(nolock)
    where Gid = @vGid
    --DTS
    exec LOGNETOBJSEQ 1195, @vUserGid, @vID, @piRcvGid, 0

    fetch next from curNTaxSort into @vGid
  end
  close curNTaxSort
  deallocate curNTaxSort

  return(0)
end
GO
