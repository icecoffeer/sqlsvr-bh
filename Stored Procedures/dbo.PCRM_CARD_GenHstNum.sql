SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[PCRM_CARD_GenHstNum]
(
 @poHstNum varchar(26) output  --出错信息
)
as
begin
  declare @vUserCode varchar(4)
  declare @vSEQ int
  
    
  select @vUserCode = UserCode from FASystem(noLock)
  exec @vSEQ = SEQNextValue 'CRMCARDHSTNUM'
    
  set @poHstNum = Ltrim(Rtrim(@vUserCode)) + Ltrim(Rtrim(Replicate('0', 10 - Len(Convert(varchar(10), @vSEQ)))))
  set @poHstNum = @poHstNum  + SubString(Convert(varchar(10), @vSEQ), 1, 10) + LTrim(RTrim(CONVERT(VARCHAR(6), GETDATE(),12) + REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108),':','')))
  return(0)
end
GO
