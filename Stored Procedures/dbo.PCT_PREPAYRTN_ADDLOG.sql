SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PREPAYRTN_ADDLOG] (
  @piNum varchar(14),
  @piFromStat integer,
  @piToStat integer,
  @piOperGid integer
) as
begin
  declare @vItemNo integer
  declare @vOper varchar(30)

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
  from EMPLOYEE(nolock) where GID = @piOperGid
  select @vItemNo = isnull(max(ITEMNO), 0) from CTPREPAYRTNLOG(nolock) where NUM = @piNum
  set @vItemNo = @vItemNo + 1
  insert into CTPREPAYRTNLOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
  values(@piNum, @vItemNo, @piFromStat, @piToStat, @vOper, getdate())
end
GO
