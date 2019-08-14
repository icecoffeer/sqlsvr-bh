SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_ADDLOG] (
  @piNum varchar(14),
  @piVersion int,
  @piOperGid int,
  @piFromStat int,
  @piToStat int,
  @piAction varchar(10)
) as
begin
  declare @vRet int
  declare @Oper varchar(50)
  declare @vItemNo int
  declare @vSettleNo int
  declare @vOper varchar(30)

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) 
  where GID = @piOperGid;
  select @vItemNo = max(ITEMNO) from CTCNTRLOG 
  where NUM = @piNum and VERSION = @piVersion;
  if @vItemNo is null
  	set @vItemNo = 1
  else
    set @vItemNo = @vItemNo + 1
  if (@piAction is null) or (@piAction = '')
    select @piAction = ACTNAME from MODULESTAT(nolock) where NO = @piToStat
  
  insert into CTCNTRLOG(NUM, VERSION, ITEMNO, FROMSTAT, TOSTAT, OPER,
		OPERTIME, SETTLENO, ACTION)
    values(@piNum, @piVersion, @vItemNo, @piFromStat, @piToStat, @vOper,
    getdate(), @vSettleNo, @piAction);
end
GO
