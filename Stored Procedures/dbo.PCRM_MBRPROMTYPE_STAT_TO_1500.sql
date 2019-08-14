SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_STAT_TO_1500] (
  @piNum varchar(14),                    --单号
  @piOper varchar(40),                   --操作人
  @poErrMsg varchar(255) output          --出错信息
) as
begin
	declare
	  @stat int
	select @stat = stat from CRMMBRPROMTYPEBILL where Num = @piNum
	if @stat <> 100
	begin
	  set @poErrMsg = '不是已审核状态，不能进行结束操作'
	  return 1
	end  
	
  delete from CRMMBRPROMSUBJINVDTL where RULEUUID in(select uuid from CRMMBRPROMSUBJINV where srcnum = @piNum)
  delete from CRMMBRPROMSUBJINV where srcnum = @piNum

  update CRMMBRPROMTYPEBILL set Stat = 1500, Modifier = @piOper, LstUpdTime = getdate()
    where Num = @piNum
  exec PCRM_MBRPROMTYPE_ADD_LOG @piNum, 100, 1500, @piOper

  return(0)
end
GO
