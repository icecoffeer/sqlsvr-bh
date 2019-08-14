SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_GenBillFromOuter]
(
  @pi_PlatForm Varchar(30) = 'UPOWER', --来源平台: Intra
  @pi_BillNum VarChar(50), --来源单号
  @pi_Direction int, --0:生成批发;1:生成批发退
  @po_Msg varchar(255) output
)
as
begin
  Declare
    @vRet int

  Set @vRet = 0
  --生成 批发单
  if @pi_Direction = 0
    Exec @vRet = PS3_GenWholeSaleFromOuterBill @pi_PlatForm, @pi_BillNum, @po_Msg Output
  else
  --生成 批发退单
    Exec @vRet = PS3_GenWholeSaleBckFromOuterBill @pi_PlatForm, @pi_BillNum, @po_Msg Output

  Return @vRet
end
GO
