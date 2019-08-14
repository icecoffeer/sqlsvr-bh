SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UPDLEAGUESTOREALCACCOUNTTOTAL]
/*从加盟店信用额度的已缴款额中扣款，并记录日志 */
(
  @NUM CHAR(10),              --单号
  @STOREGID INT,              --店号
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
    @STORENAME  VARCHAR(50),
    @account DECIMAL(24,2),
    @UseAccount int  --是否对该门店启用信用额度
  
    select @TOTAL = total, @account = account, @UseAccount = USEACCOUNT from LEAGUESTOREALCACCOUNT(nolock)
    where storegid = @STOREGID
    if @TOTAL IS NULL
    set @TOTAL = 0 
    if @account IS NULL
    set @account = 0 
    if (@TOTAL + @account - @DEDUCTTOTAL < 0) and (@UseAccount <> 0) and (@CLS <> '门店调拨单')
      begin
        raiserror('配货信用额与交款额不足,不能审核', 16, 1)
        return(5)
      end
    
    SET @FILLERCODE = RTRIM(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
    
    SELECT @FILLER = GID, @FILLERNAME = NAME 
    FROM EMPLOYEE(NOLOCK)
    WHERE CODE LIKE @FILLERCODE
    
    SELECT @STORENAME = NAME
    FROM STORE
    WHERE GID = @STOREGID

    if exists (select * from LEAGUESTOREALCACCOUNT(nolock) where STOREGID = @STOREGID)
      begin
        UPDATE LEAGUESTOREALCACCOUNT     
        SET TOTAL = TOTAL - @DEDUCTTOTAL, LSTUPDTIME = getdate(), LSTMODIFIER = @FILLERNAME + '[' + @FILLERCODE + ']'
        WHERE STOREGID = @STOREGID       
      end
    else
      begin
        insert into LEAGUESTOREALCACCOUNT(STOREGID, ACCOUNT, TOTAL, LSTUPDTIME, LSTMODIFIER)
        VALUES (@STOREGID, 0.00, -@DEDUCTTOTAL, getdate(), @FILLERNAME + '[' + @FILLERCODE + ']' )
      end
      
    INSERT INTO LEAGUESTOREALCLOG (DATE, STORE, NUM, VAL, ORITOTAL, SORT, OPER, CLS )
    VALUES (GETDATE(), @STORENAME, @NUM, @DEDUCTTOTAL, @TOTAL, 1, @FILLERNAME, @CLS)
    return(0)
END
GO
