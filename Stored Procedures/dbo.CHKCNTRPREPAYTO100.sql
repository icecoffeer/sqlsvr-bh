SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKCNTRPREPAYTO100]
(
	@NUM		VARCHAR(14),
	@OPER		VARCHAR(50),
	@MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
	declare @empgid int
	declare @empcode char(20)
	declare @i int, @j int
	declare @VRET int
	declare @SRC int
	declare @CLECENT int
	declare @USERGID int
	--PIOPER为审核人
	UPDATE CNTRPREPAY SET STAT = 100,CHECKER = @OPER WHERE NUM = @NUM
	select @i = charindex('[', @oper)
	select @j = charindex(']', @oper)
    select @empcode = rtrim(substring(@oper, @i+1, @j-@i-1))
    select @empgid = gid from employee(nolock) where code = @empcode
	insert into cntrprepaychklog(num, chkflag, oper, atime)
    values(@num, 100, @empgid, getdate())

  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SET @CLECENT = NULL
  SELECT @SRC = SRC, @CLECENT = CLECENT FROM CNTRPREPAY(NOLOCK)
    WHERE NUM = @NUM
    
  IF @SRC IS NULL RETURN 0
  IF @USERGID = @SRC
  BEGIN  
    IF @CLECENT IS NULL OR @CLECENT = @USERGID
      RETURN 0
  END  
  EXEC @VRET = PrePay_SEND @NUM, @OPER, @MSG
	 IF @VRET <> 0 RETURN @VRET

  RETURN 0 
END 
GO
