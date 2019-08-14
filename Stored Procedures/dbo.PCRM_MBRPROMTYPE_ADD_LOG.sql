SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_ADD_LOG](
  @piNum varchar(14),                 --单号
  @piStat int,                        --原状态
  @piToStat int,                      --现状态
  @piOper varchar(40)                 --操作人
) as
begin
  declare
    @vItem int
    --@vOper varchar(80)
  select @vItem = isnull(max(ITEMNO)+1, 1) from CRMMBRPROMTYPEBILLLOG(nolock) where NUM = @piNum
  --select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  insert into CRMMBRPROMTYPEBILLLOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
  values(@piNum, @vItem, @piStat, @piToStat, @piOper, getdate())
end
GO
