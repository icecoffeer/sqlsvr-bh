SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDSALE_ADD_LOG](
  @piNum char(14),                    --单号
  @piStat int,                        --原状态
  @piToStat int,                      --现状态 
  @piOperGid int                      --操作人
) as
begin
  declare @vItem int
  declare @vOper varchar(50)

  select @vItem = isnull(max(ITEMNO)+1, 1) FROM CRMCARDSALELOG(nolock) where NUM = @piNum
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  insert into CRMCARDSALELOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
  values(@piNum, @vItem, @piStat, @piToStat, @vOper, getdate())
end
GO
