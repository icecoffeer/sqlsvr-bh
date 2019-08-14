SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[VDRBEPAdj_REMOVE](
  @pi_num varchar(14),
  @oper varchar(30),
  @po_msg varchar(255) output
)with encryption
as
begin
  declare
    @stat smallint
  select @stat = STAT from VDRBEPADJ where NUM = @pi_num
  if @stat <> 0
  begin
    set @po_msg = '不是未审核的单据不能删除!'
    return 1
  end 
  delete from VDRBEPADJ where NUM = @pi_num
  delete from VDRBEPADJDTL where NUM = @pi_num 
  exec VDRBEPADJ_ADD_LOG @pi_num, -1, '删除', @Oper;   
  return 0
end
GO
