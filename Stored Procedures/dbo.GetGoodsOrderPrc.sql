SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsOrderPrc](
  @piGdGid int,
  @piVdrGid int,
  @poOrdPrice decimal(24,4) output
)
with encryption
as
begin
  declare
    @return_status int,
    @vUserGid int,
    @vPrice decimal(24,4),
    @vPrmInPrc decimal(24,4),
    @vDefPrc decimal(24,4),
    @vDefPrcStr varchar(100),
    @vSQL nvarchar(1024),
    @vParams nvarchar(255)

  --系统变量
  select @vUserGid = USERGID from SYSTEM(nolock)

  --系统默认价，取不到则为Null
  set @vDefPrc = null
  exec OptReadStr 114, 'DefaultPrice', 'LSTINPRC', @vDefPrcStr output
  if @vDefPrcStr = 'AGMTPRC'
  begin
    exec GetGoodsVdrAgmtPrc @piGdGid, @piVdrGid, @vDefPrc output
  end
  else begin
    set @vSQL = 'select @vDefPrc = ' + @vDefPrcStr
      + ' from GOODS(nolock) where GID = ' + ltrim(str(@piGdGid))
    set @vParams = '@vDefPrc decimal(24,4) output'
    exec SP_EXECUTESQL @vSQL, @vParams, @vDefPrc output
  end
  
  --促销进价，取不到则为Null
  exec @return_status = GetGoodsPrmStkInPrc
    @piVdrGid, @vUserGid, @piGdGid, @vPrmInPrc output
  if @return_status <> 0
    set @vPrmInPrc = null
  
  --系统价与促销进价的较小值
  set @vPrice = @vDefPrc
  if @vPrice is null or @vPrmInPrc <= @vPrice
    set @vPrice = @vPrmInPrc
    
  --取不到值，则取商品最新进价
  if @vPrice is null
  begin
    select @vPrice = LSTINPRC from GOODS(nolock)
      where GID = @piGdGid
  end
  
  set @poOrdPrice = @vPrice
  return 0
end
GO
