SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [dbo].[PCRM_GETOTHERSALEINFO]
(
  @PIXPOSNO varchar(50),
  @PIXFLOWNO varchar(50),
  @PISRCTRAN integer,
  @POPOSNO varchar(50) output,
  @POFLOWNO varchar(50) output,
  @POAMOUNT varchar(50) output,
  @poErrMsg varchar(255) output
) as
begin
  if @piSrcTran = 1
  begin
    select @poPosNo  = '1111'
    select @poFlowNo = '20131122050004'
    select @poAmount = '10'
  end else
  begin
    select @poPosNo  = '1121'
    select @poFlowNo = '20131122050015'
    select @poAmount = '5'
  end
  return(0)
end

GO
