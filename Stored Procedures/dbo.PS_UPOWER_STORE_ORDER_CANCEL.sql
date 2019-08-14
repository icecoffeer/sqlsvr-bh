SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PS_UPOWER_STORE_ORDER_CANCEL]
(
  @piPlatForm varchar(80),   --PS3_OnLineOrd.PlatForm
  @piOrdNo varchar(100),     --PS3_OnLineOrd.OrdNo
  @poErrMsg varchar(255) output
)
as
begin
  Declare @v_Ret int

  set @v_Ret = 0

  Return @v_Ret
end
GO
