SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_RemoveNetBill](
  @Src int,
  @ID int
)
as
begin
  delete from npolyprcprm where SRC = @Src and ID = @ID
  delete from npolyprcprmdtl where SRC = @Src and ID = @ID
  delete from npolyprcprmdtldtl where SRC = @Src and ID = @ID
  delete from npolyprcprmexgddtl where SRC = @Src and ID = @ID
  return 0
end
GO
