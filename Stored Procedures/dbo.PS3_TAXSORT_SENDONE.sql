SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_TAXSORT_SENDONE]
(
  @piGID varchar(13),           --税务分类ID
  @piRcvGid integer,            --接收门店
  @piFrcUpd int,                --是否强制更新
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vSrc int,
    @vID int

  select @vSrc = UserGid from FASystem(nolock)
  
  --取得ID号
  execute GetNetBillId @vID output

  insert into NTaxSort (SRC, ID, GID, CODE, NAME, PROVINCE, RCV, FRCUPD, TYPE, NSTAT)
  select @vSrc, @vID, GID, Code, Name, Province, @piRcvGid, @piFrcUpd, 0, 0
    from TaxSort(nolock)
  where GID = @piGID 
    --DTS
  exec LOGNETOBJSEQ 1195, @vSrc, @vID, @piRcvGid, 0

  return(0)
end
GO
