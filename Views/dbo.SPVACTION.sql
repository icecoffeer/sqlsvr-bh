SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[SPVACTION] (
  [SN],
  [ITEMNO],
  [FROMSTAT],
  [TOSTAT],
  [OPER],
  [OPERTIME],
  [SRC],
  [NOTE],
  [FILDATE],
  [SALEAMT],
  [ENSN],
  [BESOPER],
  [BESSRC],
  [HANDOPER],
  [HANDSRC]
) as
select sp.SN	   
      ,ITEMNO	   
      ,FROMSTAT    
      ,TOSTAT	   
      ,OPER	   
      ,OPERTIME    
      ,SRC	   
      ,NOTE	   
      ,FILDATE     
      ,SALEAMT     
      ,ENSN        
      ,BESOPER	
      ,BESSRC	
      ,HANDOPER
      ,HANDSRC	

from SPVOUCHERLOG log, SPVOUCHER  sp
where log.SN = sp.SN
GO
