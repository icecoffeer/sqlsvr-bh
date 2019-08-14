SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GetStoreOrdApplyTypeName](
  @piStoreOrdApplyType int,
  @poStoreOrdApplyTypeName varchar(20) output,
  @poErrMsg varchar(255) output
)
as
begin
  select @poStoreOrdApplyTypeName = rtrim(TYPENAME)
    from STOREORDAPPLYTYPE(nolock)
    where TYPE = @piStoreOrdApplyType
    and STAT = 0 --请求总部批准

  if @@rowcount = 0
  begin
    set @poErrMsg = '门店叫货申请单类型 ' + convert(varchar, @piStoreOrdApplyType) + ' 在数据库中不存在。'
    return 1
  end

  return 0
end
GO
