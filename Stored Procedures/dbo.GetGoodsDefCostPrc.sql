SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsDefCostPrc](
  @piPrcType varchar(255),      --传入参数：默认成本价类型。
  @piGdGid int,                 --传入参数：商品GID。
  @poPrice decimal(24,4) output --传出参数（返回值为0时有效）：默认成本价。
)
with encryption
as
begin
  declare
    @DefCostPrcStr varchar(255),
    @DefCostPrc decimal(24,4),
    @SQL nvarchar(255),
    @Params nvarchar(255)

  set @piPrcType = rtrim(@piPrcType)

  --获取默认成本价来源。
  if @piPrcType = '合同进价'
    set @DefCostPrcStr = 'CNTINPRC'
  else if @piPrcType = '最新进价'
    set @DefCostPrcStr = 'LSTINPRC'
  else
    set @DefCostPrcStr = 'INPRC'

  --获取默认成本价，取不到则为Null。
  set @DefCostPrc = null
  set @SQL = 'select @DefCostPrc = ' + @DefCostPrcStr
    + ' from GOODS(nolock)'
    + ' where GID = ' + convert(varchar, @piGdGid)
  set @Params = '@DefCostPrc decimal(24,4) output'
  exec SP_EXECUTESQL @SQL, @Params, @DefCostPrc output

  set @poPrice = @DefCostPrc
  return 0
end
GO
