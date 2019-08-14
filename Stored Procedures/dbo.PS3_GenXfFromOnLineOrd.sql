SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_GenXfFromOnLineOrd]
(
  @pi_PlatForm VarChar(80),
  @pi_OrdNo VarChar(50),
  @po_Msg varchar(255) output
)
as
begin

  Return 0
end
GO
