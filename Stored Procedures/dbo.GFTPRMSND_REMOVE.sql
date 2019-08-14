SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_REMOVE]
(
  @piNum	char(14),
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
)
as
begin
  declare @vStat int
  select @vStat = STAT from GFTPRMSND where NUM = @piNum;
  if @vStat not in (0, 1600)
  begin
    set @poErrMsg = @piNum + '不是未审核或已预审单据，不能删除'
    return(1)
  end

  delete from GFTPRMSND where NUM = @piNum;
  delete from GFTPRMSNDBILL where NUM = @piNum;
  delete from GFTPRMSNDSALE where NUM = @piNum;
  delete from GFTPRMSNDGIFT where NUM = @piNum;
  delete from GFTPRMSNDRULE where NUM = @piNum;
  delete from GFTPRMSNDLOG where NUM = @piNum;

  return(0)
end
GO
