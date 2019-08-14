SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREADJ_ADD_LOG]
(
  @piNum varchar(14),
  @piStat int,
  @piToStat int,
  @piOperGid int
) as
begin
  declare @vItemNo int
  declare @vOper varchar(50)
  
  select @vItemNo = isnull(max(ITEMNO)+1, 1) from CRMSCOREADJLOG(nolock) where NUM = @piNum
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) +']' from EMPLOYEE(nolock) where GID = @piOperGid
  
  insert into CRMSCOREADJLOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
    values(@piNum, @vItemNo, @piStat, @piToStat, @vOper, getdate())
end
GO
