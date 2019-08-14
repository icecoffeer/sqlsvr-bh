SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_DoRemove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  delete from POLYPRCPRM where NUM = @Num
  delete from POLYPRCPRMDTL where NUM = @Num
  delete from POLYPRCPRMDTLDTL where NUM = @Num
  delete from POLYPRCPRMLACDTL where NUM = @Num
  delete from POLYPRCPRMEXGDDTL where NUM = @Num
  return 0
end
GO
