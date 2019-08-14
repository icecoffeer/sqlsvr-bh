SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_RemoveNetBill](
  @Src int,
  @ID int
)
as
begin
  delete from NPOLYPROM where SRC = @Src and ID = @ID
  delete from NPOLYPROMRANGEDTL where SRC = @Src and ID = @ID
  delete from NPOLYPROMEXGDDTL where SRC = @Src and ID = @ID
  delete from NPOLYPROMTOTALSCHMDTL where SRC = @Src and ID = @ID
  delete from NPOLYPROMQTYSCHMDTL where SRC = @Src and ID = @ID
  return 0
end
GO
