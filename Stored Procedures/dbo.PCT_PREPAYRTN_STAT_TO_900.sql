SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PREPAYRTN_STAT_TO_900] (
  @piNum varchar(14),
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vPrePayNum varchar(14)
  declare @vTotal decimal(24, 2)
  declare @vTotalOff decimal(24, 2)
  declare @VRET int
  declare @SRC int
  declare @USERGID int

  update CTPREPAYRTN set 
    STAT = 900
  where NUM = @piNum

  select @vPrePayNum = PREPAYNUM, @vTotal = TOTAL from CTPREPAYRTN where NUM = @piNum
  update CNTRPREPAY set TOTALOFF = TOTALOFF + @vTotal where NUM = @vPrePayNum
  update CNTRPREPAY set STAT = 300 where NUM = @vPrePayNum and TOTALOFF >= TOTAL
  
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SELECT @SRC = SRC FROM CTPREPAYRTN(NOLOCK)
    WHERE NUM = @piNum
    
  IF @SRC = @USERGID RETURN 0 --计算中心付款操作不发送
  EXEC @VRET = CTPrePay_SEND @piNum, 0, @poErrMsg
	 IF @VRET <> 0 RETURN @VRET

  return(0)
end
GO
