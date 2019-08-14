SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_CURRENT_VERSION] (
  @piNum char(14),
  @poVersion int output
) as
begin
  select @poVersion = VERSION from CNTRGROUP(nolock) where NUM = @piNum and TAG = 1;
end;
GO
