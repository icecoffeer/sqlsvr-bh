SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[APPEND_SETTLEDAYRESULT](
    @piSETTLEDAY datetime,
    @piPROCNAME varchar(100),
    @piRESULT smallint,
    @piNOTE varchar(255)
) as
begin
  if not exists(select 1 from SettleDayRunResult(nolock) where  SettleDay = convert(varchar(12), @piSettleDay, 102) 
        and ProcName = @piProcName)          
    insert into SettleDayRunResult(SettleDay, ProcName, nResult, Note)
    values(convert(varchar(12), @piSettleDay, 102), @piProcName, @piResult, @piNote)
  else
    update SettleDayRunResult set nResult = @piResult, Note = @piNote 
    where SettleDay = convert(varchar(12), @piSettleDay, 102) and ProcName = @piProcName  
end
GO
