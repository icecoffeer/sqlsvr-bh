SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_ON_CHGBOOK_REMOVE]
(
  @piNum	char(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
/*  declare @vCntrNum varchar(14)

  select @vCntrNum = CNTRNUM from CHGBOOK(nolock) where NUM = @piNum and BTYPE in (1, 2)
  if @@rowcount = 0 return(0)
  if isnull(@vCntrNum, '') = '' return(0)
  update CNTRDTLDATE set 
    CHGBOOKNUM = null
  where NUM = @vCntrNum and CHGBOOKNUM = @piNum*/

  return(0)
end
GO
