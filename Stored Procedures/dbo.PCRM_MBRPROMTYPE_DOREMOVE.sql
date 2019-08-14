SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_DOREMOVE] (
  @piNum varchar(14),                     --单号
  @poMsg varchar(255) output           --出错信息
) as
begin
  delete from CRMMBRPROMTYPEBILL where NUM = @piNum
  delete from CRMMBRPROMTYPEBILLDTL where NUM = @piNum

  Set @poMsg = ''
  return(0)
end
GO
