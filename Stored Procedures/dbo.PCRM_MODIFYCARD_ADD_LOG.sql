SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MODIFYCARD_ADD_LOG](
  @piNum char(14),                    --单号
  @piStat int,                        --原状态
  @piToStat int,                      --现状态 
  @piOper varchar(70)                 --操作人
) as
begin
  declare 
    @vItem int

  select @vItem = isnull(max(ITEMNO)+1, 1) FROM CRMMODIFYCARDLOG(nolock) where NUM = @piNum
  insert into CRMMODIFYCARDLOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
  values(@piNum, @vItem, @piStat, @piToStat, @piOper, getdate())
end
GO
