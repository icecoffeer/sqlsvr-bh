SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[WMSFILTER](
  @piTableName varchar(50),
  @piCls Char(10),
  @piNum Char(14),
  @piToStat SmallInt,
  @piOper Char(30),
  @piWrh Int,
  @piTag Int,
  @piAct VarChar(50),
  @poMsg VarChar(255) Output
)
With Encryption
As
begin
  return 0
end
GO
