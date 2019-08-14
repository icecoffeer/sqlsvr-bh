SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PREPAYRTN_STAT_TO_100] (
  @piNum varchar(14),
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare
    @VRET int, 
    @SRC int, 
    @CLECENT int,
    @USERGID int
    
  update CTPREPAYRTN set 
    STAT = 100,
    CHECKER = @piOperGid,
    CHKDATE = getdate()
  where NUM = @piNum
  
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SET @CLECENT = NULL
  SELECT @SRC = SRC, @CLECENT = CLECENT FROM CTPREPAYRTN(NOLOCK)
    WHERE NUM = @piNum
    
  IF @SRC IS NULL RETURN 0
  IF @USERGID = @SRC
  BEGIN  
    IF @CLECENT IS NULL OR @CLECENT = @USERGID
      RETURN 0
  END  
  EXEC @VRET = CTPrePay_SEND @piNum, 0, @poErrMsg
	 IF @VRET <> 0 RETURN @VRET
  
  return(0)
end
GO
