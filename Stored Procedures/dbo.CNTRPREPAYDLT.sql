SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CNTRPREPAYDLT]
(
	@NUM		VARCHAR(14),
	@OPER		VARCHAR(50),
	@CLS		VARCHAR(10),
	@TOSTAT		INT,
	@MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @Vstat int
	declare @empgid int
	declare @empcode char(20)
	declare @i int, @j int
	declare @VRET int
	declare @SRC int
	declare @USERGID int

	Select @VStat = stat
	from CNTRPREPAY where num = @NUM
	IF @@ROWCOUNT = 0
	BEGIN
		SELECT @MSG = '预付款单'+@NUM+'不存在。'
		return 1
	END

	If @vStat <> 100
	BEGIN
		SELECT @MSG = '作废的不是已审核的单据.'
		return 1
	end
	UPDATE CNTRPREPAY SET STAT = 110, NOTE = LTRIM(NOTE) + ' 作废人:' + @OPER
	where num = @NUM

	select @i = charindex('[', @oper)
	select @j = charindex(']', @oper)
    select @empcode = rtrim(substring(@oper, @i+1, @j-@i-1))
    select @empgid = gid from employee(nolock) where code = @empcode
	insert into cntrprepaychklog(num, chkflag, oper, atime)
    values(@num, 110, @empgid, getdate())
    
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SELECT @SRC = SRC FROM CNTRPREPAY(NOLOCK)
    WHERE NUM = @NUM
    
  IF @SRC = @USERGID RETURN 0 --计算中心作废操作不发送
  EXEC @VRET = PrePay_SEND @NUM, @OPER, @MSG
	 IF @VRET <> 0 RETURN @VRET 

  RETURN 0 
END 
GO
