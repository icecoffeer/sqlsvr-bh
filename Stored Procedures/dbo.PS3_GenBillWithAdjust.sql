SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_GenBillWithAdjust]
(
  @pi_PlatForm Varchar(30) = 'Intra', --来源平台: Intra
  @pi_BillNum VarChar(50), --来源单号
  @po_Msg varchar(255) output
)
as
begin
  Declare
    @vRet int

  Set @vRet = 0
  --生成 批发单
  Exec @vRet = PS3_GenWholeSaleFromOuterBill @pi_PlatForm, @pi_BillNum, @po_Msg Output
  If @vRet <> 0
  Begin
    Set @po_Msg = SubString('生成批发单失败:' + @po_Msg, 1, 255)
    Return @vRet
  End
  --生成 批发退单
  Exec @vRet = PS3_GenWholeSaleBckFromOuterBill @pi_PlatForm, @pi_BillNum, @po_Msg Output
  If @vRet <> 0
  Begin
    Set @po_Msg = SubString('生成批发退单失败:' + @po_Msg, 1, 255)
    Return @vRet
  End

  Return 0
end
GO
