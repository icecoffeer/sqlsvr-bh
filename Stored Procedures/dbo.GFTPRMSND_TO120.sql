SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_TO120]
(
  @piNum	char(14),
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from GFTPRMSND where NUM = @piNum;
  if @vStat <> 100
  begin
    set @poErrMsg = @piNum + '不是已审核单据，不能冲单'
    return(1)
  end

  if exists(select 1 from GFTPRMBCK where SNDNUM = @piNum and STAT = 100)
  begin
    set @poErrMsg = '赠品已经回收，无法冲单赠品发放单'
    return(1)
  end

  --产生负单
  exec @vRet = GFTPRMSND_NEG @piNum, @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet)

  update GFTPRMSND set STAT = 130, LSTUPDTIME = getdate() where NUM = @piNum;
  exec GFTPRMSND_ADDLOG @piNum, 130, @piOperGid

  return 0
end
GO
