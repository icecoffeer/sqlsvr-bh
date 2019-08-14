SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRM_BAL]
(
  @piNum char(10),
  @piOper int,
  @poErrMsg varchar(255) output
) as
begin
  declare
    @stat smallint,
    @USERGID int
  select @stat = stat from prcprm where num = @piNum
  SELECT @USERGID = USERGID FROM SYSTEM
  select @poErrMsg = ''
  if (@stat <> 1) /*只作废已审核单据 POS-3343 edit by qzh*/
  begin
    select @poErrMsg = '要作废的单据不是已审核状态，不能作废。'
    return(1)
  end
  delete from Price where SrcNum = @piNum
  update prcprm set stat = 21 where num = @piNum
  return(0)
end
GO
