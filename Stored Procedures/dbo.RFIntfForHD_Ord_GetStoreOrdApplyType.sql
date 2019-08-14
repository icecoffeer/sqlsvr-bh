SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GetStoreOrdApplyType](
  @poErrMsg varchar(255) output
)
as
begin
  select distinct TYPE 类型代码, TYPENAME 类型名称
    from STOREORDAPPLYTYPE(nolock)
    order by TYPE

  return 0
end
GO
