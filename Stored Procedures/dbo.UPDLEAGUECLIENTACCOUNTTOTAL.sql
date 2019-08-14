SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UPDLEAGUECLIENTACCOUNTTOTAL]
/*从客户信用额度的已缴款额中扣款，并记录日志 */
(
  @NUM CHAR(10),              --单号
  @CLIENTGID INT,              --店号
  @CLS VARCHAR(30),           --类型
  @DEDUCTTOTAL DECIMAL(24,2)  --扣款额
)
AS
BEGIN
  DECLARE
    @TOTAL DECIMAL(24,2),
    @FILLERCODE VARCHAR(20), 
    @FILLER INT, 
    @FILLERNAME VARCHAR(50),
    @CLIENTNAME  VARCHAR(50),
    @account DECIMAL(24,2),
    @UseAccount int  --ShenMin
  
    select @TOTAL = total, @account = account, @UseAccount = USEACCOUNT from LEAGUECLIENTACCOUNT(nolock)
    where CLIENTgid = @CLIENTGID
    if @TOTAL IS NULL
    set @TOTAL = 0 
    if @account IS NULL
    set @account = 0 
    if (@TOTAL + @account - @DEDUCTTOTAL < 0) and (@UseAccount <> 0) --ShenMin
      begin
        raiserror('信用额与交款额不足,不能审核', 16, 1)
        return(5)
      end
    
    SET @FILLERCODE = RTRIM(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
    
    SELECT @FILLER = GID, @FILLERNAME = NAME 
    FROM EMPLOYEE(NOLOCK)
    WHERE CODE LIKE @FILLERCODE
    
    SELECT @CLIENTNAME = NAME
    FROM CLIENT
    WHERE GID = @CLIENTGID

    if exists (select * from LEAGUECLIENTACCOUNT(nolock) where CLIENTGID = @CLIENTGID)
      begin
        UPDATE LEAGUECLIENTACCOUNT     
        SET TOTAL = TOTAL - @DEDUCTTOTAL, LSTUPDTIME = getdate(), LSTMODIFIER = @FILLERNAME + '[' + @FILLERCODE + ']'
        WHERE CLIENTGID = @CLIENTGID       
      end
    else
      begin
        insert into LEAGUECLIENTACCOUNT(CLIENTGID, ACCOUNT, TOTAL, LSTUPDTIME, LSTMODIFIER)
        VALUES (@CLIENTGID, 0.00, -@DEDUCTTOTAL, getdate(), @FILLERNAME + '[' + @FILLERCODE + ']' )
      end
      
    INSERT INTO LEAGUECLIENTLOG (DATE, CLIENT, NUM, VAL, ORITOTAL, SORT, OPER, CLS )
    VALUES (GETDATE(), @CLIENTNAME, @NUM, @DEDUCTTOTAL, @TOTAL, 1, @FILLERNAME, @CLS)
    return(0)
END
GO
