SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKCNTRPREPAYTO900]
(
	@NUM		VARCHAR(14),
	@OPER		VARCHAR(50),
	@ERR_MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
	declare @empgid int
	declare @empcode char(20)
	declare @i int, @j int
	declare @VRET int
	declare @SRC int
	declare @USERGID int
	--PIOPER为付款人
	UPDATE CNTRPREPAY SET STAT = 900,PAYER = @OPER WHERE NUM = @NUM
	select @i = charindex('[', @oper)
	select @j = charindex(']', @oper)
    select @empcode = rtrim(substring(@oper, @i+1, @j-@i-1))
    select @empgid = gid from employee(nolock) where code = @empcode
	insert into cntrprepaychklog(num, chkflag, oper, atime)
    values(@num, 900, @empgid, getdate())
    
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SELECT @SRC = SRC FROM CNTRPREPAY(NOLOCK)
    WHERE NUM = @NUM
    
  IF @SRC = @USERGID RETURN 0 --计算中心付款操作不发送
  EXEC @VRET = PrePay_SEND @NUM, @OPER, @ERR_MSG
	 IF @VRET <> 0 RETURN @VRET 
  
  RETURN 0 
END 
GO
