SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[WMSSTKOUTBCKCHKFILTERBCK](
  @piCls Char(10),
  @piNum Char(14),
  @piToStat SmallInt,
  @piOper Char(30),
  @piTag Int,
  @piAct VarChar(50),
  @poMsg VarChar(255) Output
)
--With Encryptions
As
begin
  return 0
end
GO
