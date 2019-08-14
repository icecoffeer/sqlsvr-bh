SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRM_END]
(
  @piNum char(10),
  @piOper int,
  @poErrMsg varchar(255) output
) as
begin
  declare
    @stat smallint
  select @stat = stat from prcprm where num = @piNum
  select @poErrMsg = ''
  if (@stat <> 5)
  begin
    select @poErrMsg = '要终止的单据不是已生效状态，不能终止。'
    return(1)
  end	
  delete from Price where SrcNum = @piNum
  update prcprm set stat = 22 where num = @piNum
  return(0)
end
GO
