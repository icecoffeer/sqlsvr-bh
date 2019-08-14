SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[PCRM_CARD_CalAccuCon]
(
 @piCardNum varchar(20), ---卡号
 @piCarrier Int,
 @piConDate datetime,
 @piAmount money,
 @poErrMsg varchar(255) output  --出错信息 
)
as
begin  
  declare @nCount int
  
  select @nCount = Count(1) from CRMCardAccuCon(nolock) 
  where CardNum = @piCardNum and Carrier = @piCarrier and ConDate = @piConDate
  if @nCount = 0 
    insert into CRMCardAccuCon(CardNum, Carrier, ConDate, ConSume)
    values(@piCardNum, @piCarrier, @piConDate, @piAmount)
  else
    update CRMCardAccuCon set ConSume = ConSume + @piAmount
    where CardNum = @piCardNum and Carrier = @piCarrier and ConDate = @piConDate
  
  return(0)
end
GO
