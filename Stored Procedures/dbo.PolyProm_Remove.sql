SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_Remove](
  @Num char(14),
  @Cls char(10),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @Stat int
  
  /*检查*/
  select @Stat = STAT from POLYPROM(nolock) where NUM = @Num and CLS = @Cls
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能删除。'
    return 1
  end
  
  /*删除*/
  exec @return_status = PolyProm_DoRemove @Num, @Cls, @Msg output
  if @return_status = 0
    delete from POLYPROMLOG where NUM = @Num and CLS = @Cls
  else
    return 1
  
  return 0
end
GO
