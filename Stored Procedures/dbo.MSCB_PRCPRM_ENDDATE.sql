SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_PRCPRM_ENDDATE]   
as  
begin  
  exec MSCB_INPRCPRM_ENDDATE  --进价  
  exec MSCB_PRCPRCPRM_ENDDATE --售价  
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'MSCB_PRCPRM_ENDDATE', 0, ''    --合并日结
end  

GO
