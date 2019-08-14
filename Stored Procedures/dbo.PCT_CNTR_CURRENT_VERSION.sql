SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_CURRENT_VERSION] (
  @piNum char(14),
  @poVersion int output
) as
begin
  select @poVersion = VERSION from CTCNTR(nolock) where NUM = @piNum and TAG = 1;
end;
GO
