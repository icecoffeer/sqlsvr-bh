SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetWarehouseName](
  @piEmpCode varchar(10),
  @piWrhCode varchar(10),
  @poWrhName varchar(50) output,
  @poErrMsg varchar(255) output
)
as
begin
  --检查传入参数。
  if @piWrhCode is null or rtrim(@piWrhCode) = ''
  begin
    set @poErrMsg = '仓位代码不能为空。'
    return 1
  end

  --获取仓位名称。
  select
    @poWrhName = rtrim(NAME)
    from WAREHOUSE(nolock)
    where CODE = @piWrhCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '仓位代码 ' + rtrim(@piWrhCode) + ' 在数据库中不存在。'
    return 1
  end

  return 0
end
GO
