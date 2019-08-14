SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[PS3_GetInvCost]
(
  @GdGid Int
)
RETURNS Money
AS
BEGIN
  DECLARE
    @v_InvCost Money,
    @v_UserGid Int,
    @v_Total Money,
    @v_Qty Money

  Select @v_UserGid = USERGID From System

  SELECT @v_Total = SUM(TOTAL), @v_Qty = SUM(QTY)
    FROM INV(NOLOCK)
  WHERE STORE = @v_UserGid
    AND GDGID = @GdGid
  If @v_Qty <> 0
    Set @v_InvCost = @v_Total / @v_Qty
  Else
    Set @v_InvCost = 0

  RETURN @v_InvCost
END
GO
