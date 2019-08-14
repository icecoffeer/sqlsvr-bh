SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PURCHASEORDBCK_CHECK_100TO3300]
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
  update PURCHASEORDER set Stat = @ToStat, LSTUPDTIME = getdate()
  where num = @NUM and cls = @CLS

  EXEC PURCHASEORDERADDLOG @NUM, @CLS, 3300, '暂时确认', @OPER

  return(0)
end
GO
