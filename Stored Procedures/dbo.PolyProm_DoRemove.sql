SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_DoRemove](
  @Num char(14),
  @Cls char(10),
  @Msg varchar(255) output
)
as
begin
  delete from POLYPROM where NUM = @Num and CLS = @Cls
  delete from POLYPROMRANGEDTL where NUM = @Num and CLS = @Cls
  delete from POLYPROMEXGDDTL where NUM = @Num and CLS = @Cls
  delete from POLYPROMTOTALSCHMDTL where NUM = @Num and CLS = @Cls
  delete from POLYPROMQTYSCHMDTL where NUM = @Num and CLS = @Cls
  delete from POLYPROMLACDTL where NUM = @Num and CLS = @Cls
  return 0
end
GO
