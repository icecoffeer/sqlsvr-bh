SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[StkOutChkex_Custom](
  @Cls Char(10),
  @Num Char(14),
  @Msg VarChar(255) Output
)
--With Encryptions
As
begin
  return 0
end
GO
