SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PURCHASEORDBCK_CHECK_0TO100]
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
  update PURCHASEORDER set CHECKER = @OPER, CHECKDATE = getdate(), Stat = @ToStat, LSTUPDTIME = getdate()
  where num = @NUM and cls = @CLS

  EXEC PURCHASEORDERADDLOG @NUM, @CLS, 100, '审核', @OPER

  return(0)
end
GO
