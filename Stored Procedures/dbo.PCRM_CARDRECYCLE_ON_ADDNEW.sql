SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_CARDRECYCLE_ON_ADDNEW] (
  @piNum char(14),                     --单号
  @piOper varchar(30),                 --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  update CRMCardRecycle set Stat = 0, Modifier = @piOper, LstUpdTime = getdate() where Num = @piNum
  exec PCRM_CARDRECYCLE_ADD_LOG @piNum, null, 0, @piOper
  return(0)
end
GO
