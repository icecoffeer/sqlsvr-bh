SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_CollectFromOnLineOrd]
(
  @pi_PlatForm Varchar(30) = 'UPOWER', --订单平台: 默认UPOWER,支持扩展
  @pi_OrdNo VarChar(50), --鼎力云订单号
  @pi_Direction int, --0:集货指令;1:取消集货指令
  @po_Msg varchar(255) output
)
as
begin
  Declare
    @vOptClcMode int,
    @vRet int

  Exec OptReadInt 0, 'PS3_ClcModeFromOnLineOrd', 0, @vOptClcMode output

  Set @vRet = 0
  --生成 内部调拨单
  if @vOptClcMode = 0
  begin
    if @pi_Direction = 0
      Exec @vRet = PS3_GenXfFromOnLineOrd @pi_PlatForm, @pi_OrdNo, @po_Msg Output
    else
      Exec @vRet = PS3_GenXfRevertFromOnLineOrd @pi_PlatForm, @pi_OrdNo, @po_Msg Output
  end else
  --生成 线上销售订货单
  begin
    Exec @vRet = PS3_GenSaleOrdFromOnLineOrd @pi_PlatForm, @pi_OrdNo, @pi_Direction, @po_Msg Output
  end

  Return @vRet
end
GO
