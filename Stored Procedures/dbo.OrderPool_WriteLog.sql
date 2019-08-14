SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_WriteLog](
  @piAType smallint, /*0: Info; 1: Warning; 2: Error*/
  @piACaller varchar(50),
  @piAContent text
)
as
begin
  declare
    @vSettleNo int
  select @vSettleNo = isnull(max(NO), 0) from MONTHSETTLE(nolock)
  insert into ORDERPOOLLOG(ATIME, SETTLENO, ATYPE, ACALLER, CONTENT)
  values(getdate(), @vSettleNo, @piAType, @piACaller, @piAContent)
  return 0
end
GO
