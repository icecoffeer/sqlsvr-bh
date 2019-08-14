SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsStkInDefPrc](
  @piPriceType int,             --传入参数：进货类单据默认价格类型。
  @piVdrGid int,                --传入参数：供应商GID。
  @piGdGid int,                 --传入参数：商品GID。
  @poPrice decimal(24,4) output --传出参数（返回值为0时有效）：收货单价。
)
with encryption
as
begin
  declare
    @return_status int,
    @SQL nvarchar(255),
    @Params nvarchar(255),
    @DefPrcStr varchar(255),
    @DefPrc decimal(24,4)

  --获取系统默认价来源。
  set @DefPrcStr = case @piPriceType
    when 0 then 'LSTINPRC'
    when 1 then 'INPRC'
    when 2 then 'RTLPRC'
    when 3 then 'CNTINPRC'
    when 4 then 'WHSPRC'
    when 5 then 'INVPRC'
    when 6 then 'LWTRTLPRC'
    when 7 then 'OLDINVPRC'
    when 8 then 'MBRPRC'
    when 9 then 'MKTINPRC'
    when 10 then 'MKTRTLPRC'
    when 11 then 'AGMTPRC'
    else 'INPRC'
    end

  --获取系统默认价，取不到则为Null。
  set @DefPrc = null
  if rtrim(@DefPrcStr) = 'AGMTPRC'
  begin
    --供应商贸易协议价。
    exec GetGoodsVdrAgmtPrc @piGdGid, @piVdrGid, @DefPrc output
  end
  else begin
    --商品价格。
    set @SQL = 'select @DefPrc = ' + @DefPrcStr
      + ' from GOODS(nolock) where GID = ' + convert(varchar, @piGdGid)
    set @Params = '@DefPrc decimal(24,4) output'
    exec SP_EXECUTESQL @SQL, @Params, @DefPrc output
  end

  set @poPrice = @DefPrc
  return 0
end
GO
