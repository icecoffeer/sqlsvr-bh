SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Gen_OrdRecord](
  @piNum char(10),
  @piGdGid int,
  @piVdrGid int,
  @piWrh int,
  @piQty decimal(24,4),
  @piPrice decimal(24,4),
  @piOperGid int,
  @piRoundType char(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vUserGid int,
    @vIsLtd int,
    @vQty decimal(24,4),
    @vLine int,
    @vPrice decimal(24,4),
    @vTaxRate decimal(24,4),
    @vQpc decimal(24,4),
    @vInvQty decimal(24,4),
    @vGdGid int,
    @vIsGft smallint

  select @vUserGid = USERGID from SYSTEM(nolock)

  --限制定货和清场品判断
  exec GetGoodsOutIsLtd @vUserGid, @piGdGid, @vIsLtd output
  if (@vIsLtd & 2 = 2) or (@vIsLtd & 8 = 8)
  begin
    set @poErrMsg = '商品 ' + ltrim(str(@piGdGid)) + ' 是限制定货或清场品。'
    exec OrderPool_WriteLog 1, 'SP:OrderPool_Gen_OrdRecord', @poErrMsg
    return 0
  end

  --计算有关明细值
  select @vLine = DTLCNT from ORDERPOOLGENBILLS(nolock)
    where BILLNAME = '定货单' and NUM = @piNum and FLAG = 0

  --库存数量
  select @vInvQty = IsNull(AVLQTY, 0)
    from V_ALCINV(nolock)
    where GDGID = @piGdGid and WRH = @piWrh and STORE = @vUserGid
  if @vInvQty is null
    set @vInvQty = 0

  --取得数量
  exec @return_status = OrderPool_Gen_Unit @piNum, @piVdrGid, @piGdGid, @piQty, @piRoundType, @poErrMsg output
  if @return_status <> 0
    return @return_status
  --插入一条主商品及其赠品
  if object_id('C_OrderPoolQtyTemp') is not null deallocate C_OrderPoolQtyTemp
  declare C_OrderPoolQtyTemp cursor for
    select GDGID, ISGFT, QTY from ORDERPOOLQTYTEMP(nolock)
    where SPID = @@spid
  open C_OrderPoolQtyTemp
  fetch next from C_OrderPoolQtyTemp into @vGdGid, @vIsGft, @vQty
  while @@fetch_status = 0
  begin
    select @vTaxRate = TAXRATE, @vQpc = IsNull(QPC, 1)
      from GOODS(nolock) where GID = @vGdGid
    if @vQpc = 0
      set @vQpc = 1
    if @vIsGft = 0
    begin
      --取得价格
      exec OrderPool_Gen_Price
        @piGdGid, @piVdrGid, @piPrice, @vPrice output, @poErrMsg output
      --插入或更新明细
      if not exists(select 1 from ORDDTL(nolock)
        where NUM = @piNum and GDGID = @vGdGid and FROMGID = @piGdGid and FLAG = 0)
      begin
        set @vLine = @vLine + 1
        insert into ORDDTL(SETTLENO, NUM, LINE, GDGID, CASES, QTY, PRICE,
          TOTAL, TAX, WRH, INVQTY, FROMGID, FLAG)
        values(-1, @piNum, @vLine, @vGdGid, @vQty / @vQpc, @vQty, @vPrice,
          round(@vQty * @vPrice, 2), round(@vQty * @vPrice * @vTaxRate / (100 + @vTaxRate), 2),
          @piWrh, @vInvQty, @piGdGid, 0)
      end
      else begin
        update ORDDTL set
          CASES = (QTY + @vQty) / @vQpc, QTY = QTY + @vQty,
          TOTAL = convert(decimal(20, 2), (QTY + @vQty) * @vPrice),
          TAX = convert(decimal(20, 2), (QTY + @vQty) * @vPrice * @vTaxRate / (100 + @vTaxRate))
        where NUM = @piNum and GDGID = @vGdGid and FROMGID = @vGdGid and FLAG = 0
      end
    end
    else begin
      if not exists(select 1 from ORDDTL(nolock)
        where NUM = @piNum and GDGID = @vGdGid and FROMGID = @piGdGid and FLAG = 1)
      begin
        set @vLine = @vLine + 1
        insert into ORDDTL(SETTLENO, NUM, LINE, GDGID, CASES, QTY, PRICE,
          TOTAL, TAX, WRH, FROMGID, FLAG)
        values(-1, @piNum, @vLine, @vGdGid, @vQty / @vQpc, @vQty, 0,
          0, 0, @piWrh, @piGdGid, 1)
      end
      else begin
        update ORDDTL
          set QTY = QTY + @vQty
          where NUM = @piNum and GDGID = @vGdGid and FROMGID = @piGdGid and FLAG = 1
      end
    end

    fetch next from C_OrderPoolQtyTemp into @vGdGid, @vIsGft, @vQty
  end
  close C_OrderPoolQtyTemp
  deallocate C_OrderPoolQtyTemp

  --增加生成单据表中单据明细记录数
  update ORDERPOOLGENBILLS
    set DTLCNT = @vLine
    where BILLNAME = '定货单' and NUM = @piNum and FLAG = 0

  return (0)
end
GO
