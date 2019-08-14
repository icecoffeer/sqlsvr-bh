SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[PS3_GenWholeSaleFromOnLineOrd]
(
  @pi_PlatForm VarChar(80),
  @pi_OrdNo VarChar(50),
  @po_Msg varchar(255) output
)
as
begin
  return 0
end
GO
