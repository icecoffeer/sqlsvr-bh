SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsOrderMaxPrc](
  @piGdGid int,
  @piVdrGid int,
  @poOrdMaxPrice decimal(24,4) output
)
with encryption
as
begin
  declare
    @return_status int,
    @vUserGid int,
    @vPrice decimal(24,4),
    @vDefPrice decimal(24,4),
    @vVdrAgmtPrc decimal(24,4),
    @vPrmInPrc decimal(24,4),
    @vSQL nvarchar(4000),
    @vParams nvarchar(4000),
    @vMaxPriceChar varchar(255)

  --系统变量
  select @vUserGid = USERGID from SYSTEM(nolock)

  --默认定货单价价格
  exec GetGoodsOrderPrc @piGdGid, @piVdrGid, @vDefPrice output

  --最高价格描述文字
  exec OPTREADSTR 114, 'MAXPRICE', '', @vMaxPriceChar output
  if @vMaxPriceChar = ''
  begin
  	set @poOrdMaxPrice = @vDefPrice
  	return 0
  end
  
  set @vMaxPriceChar = replace(@vMaxPriceChar, '代销价', 'GOODS.DXPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '核算价', 'GOODS.INPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '核算售价', 'GOODS.RTLPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '最新进价', 'GOODS.LSTINPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '批发价', 'GOODS.WHSPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '最低售价', 'GOODS.LWTRTLPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '会员价', 'GOODS.MBRPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '库存价', 'GOODS.INVPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '合同进价', 'GOODS.CNTINPRC')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '促销进价', 'INPRICE.PRICE')
  set @vMaxPriceChar = replace(@vMaxPriceChar, '贸易协议价', 'AGMTPRC')
  
  if charindex('INPRICE.PRICE', @vMaxPriceChar) > 0
  begin
  	exec @return_status = GetGoodsPrmStkInPrc
  	  @piVdrGid, @vUserGid, @piGdGid, @vPrmInPrc output
  	if @return_status <> 0
  	begin
  		--促销进价不存在
  		set @poOrdMaxPrice = @vDefPrice
  	  return 0
  	end
    else begin
      set @vMaxPriceChar = replace(@vMaxPriceChar, 'INPRICE.PRICE', convert(varchar, @vPrmInPrc))
    end
  end
  
  if charindex('AGMTPRC', @vMaxPriceChar) > 0
  begin
  	exec GetGoodsVdrAgmtPrc @piGdGid, @piVdrGid, @vVdrAgmtPrc output
  	if @return_status <> 0
  	begin
  		--供应商贸易协议价不存在
  		set @poOrdMaxPrice = @vDefPrice
  	  return 0
  	end
    else begin
      set @vMaxPriceChar = replace(@vMaxPriceChar, 'AGMTPRC', convert(varchar, @vVdrAgmtPrc))
    end
  end
  
  set @vSQL = 'select @poOrdMaxPrice = ' + @vMaxPriceChar + ' from GOODS(nolock)' +
    ' where GID = ' + convert(varchar, @piGdGid)
  set @vParams = '@poOrdMaxPrice decimal(24,4) output'
  exec SP_EXECUTESQL @vSQL, @vParams, @poOrdMaxPrice output
  if @poOrdMaxPrice is null
  begin
    set @poOrdMaxPrice = @vDefPrice
  end
  
  return 0
end
GO
