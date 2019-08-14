SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_CHECK]
(
  @piNum	char(14),
  @piToStat	int,
  @piOperGid	int,
  @poErrMsg	varchar(100)	output
)
as
begin
  declare @vStat int
  declare @vRet int
  declare @vActName varchar(30)
  declare @vStatName varchar(30)

  select @vStat = STAT from GFTPRMSND where NUM = @piNum;
  if (@vStat = 0) and (@piToStat in (1600, 100))
  begin
    exec @vRet = GFTPRMSND_TO1600 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 return(@vRet)
    if @piToStat = 1600 return(0)
  end
  if (@vStat in (0, 1600)) and (@piToStat = 100)
  begin
    exec @vRet = GFTPRMSND_TO100 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 return(@vRet)
    if @piToStat = 100 return(0)
  end
  if (@vStat = 100) and (@piToStat = 120)
  begin
    exec @vRet = GFTPRMSND_TO120 @piNum, @piOperGid, @poErrMsg output
    return(@vRet)
  end

  select @vActName = actname from modulestat where no = @piToStat;
  select @vStatName = statname from modulestat where no = @vStat;
  set @poErrMsg = '不能' + rtrim(@vActName) + '状态为' + rtrim(@vStatName) + '的赠品发放单'
  return(1);
end
GO
