SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_ADDLOG]
(
  @piNum	char(14),
  @piStat	int,
  @piOperGid	int
)
as
begin
  insert into GFTPRMSNDLOG(NUM, STAT, modifier, time)
  select @piNum, @piStat, rtrim(e.name) + '[' + rtrim(e.code) + ']', getdate()
  from EMPLOYEE e(nolock) where GID = @piOperGid;

  return(0)
end
GO
