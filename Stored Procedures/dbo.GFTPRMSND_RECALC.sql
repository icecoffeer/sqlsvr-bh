SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_RECALC]
(
  @piNum	char(14),
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
)
as
begin
  return(0)
end
GO
