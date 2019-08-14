SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_REMOVE] (
  @piNum varchar(14),                 --费用单单号
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vStat integer
  declare @vBType integer

  select @vStat = STAT, @vBType = BTYPE from CHGBOOK where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到费用单' + @piNum
    return(1)
  end
  if @vStat <> 0
  begin
    set @poErrMsg = '不是未审核的费用单，无法删除'
    return(1)
  end
  if @vBType <> 0
  begin
    if not exists(select 1 from HDOPTION(nolock) where MODULENO = 3110 
      and OPTIONCAPTION = '允许删除非手工生成的费用单' and OPTIONVALUE = '是')
    begin
      set @poErrMsg = '不是手工填写的费用单不允许删除'
      return(1)
    end
  end
  
  delete from CHGBOOK where NUM = @piNum
  delete from CHGBOOKLOG where NUM = @piNum

  return(0)
end
GO
