SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PURCHASEORDER_CHECK_0TO1600]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
with Encryption
as
begin
  DECLARE
    @poNum char(14),
    @stat smallint,
    @EMPGID INT

  select @poNum = SRCNUM from PURCHASEORDER(NOLOCK) where NUM = @NUM and CLS = @CLS

  select @stat = STAT from PURCHASEORDER(NOLOCK) where NUM = @poNum and CLS = '销售定货'
  if @stat <> 3200
  begin
     select @Msg = '当前销售定货进货单的来源销售定货单[' + @poNum + ']的状态不是已确认,不允许预审'
     return(1)
  end
  SELECT @EMPGID = GID FROM EMPLOYEE(NOLOCK) WHERE
    CODE = SUBSTRING(@OPER, CHARINDEX('[',@OPER) + 1, LEN(@OPER) - CHARINDEX('[',@OPER) - 1)
    AND NAME = SUBSTRING(@OPER, 1, CHARINDEX('[',@OPER) - 1)

  update PURCHASEORDER set PRECHECKER = @EMPGID, PRECHKDATE = getdate(), Stat = @TOSTAT, LSTUPDTIME = getdate()
  where num = @NUM and cls = @CLS

  EXEC PURCHASEORDERADDLOG @NUM, @CLS, 1600, '预审', @OPER
  return(0)
end
GO
