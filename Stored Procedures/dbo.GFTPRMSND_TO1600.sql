SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_TO1600]
(
  @piNum	char(14),
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vStat int
  select @vStat = STAT from GFTPRMSND where NUM = @piNum;
  if @vStat <> 0
  begin
    set @poErrMsg = @piNum + '不是未审核单据，不能预审'
    return(1)
  end

  update GFTPRMSND set STAT = 1600, LSTUPDTIME = getdate() where NUM = @piNum;
  exec GFTPRMSND_ADDLOG @piNum, 1600, @piOperGid

  return(0)
end
GO
