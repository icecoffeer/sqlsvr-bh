SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetGoods_AmtQty](
  @piBarCode varchar(40),       --条码
  @poGdGid int output,          --商品内码
  @poQty decimal(24,4) output,  --条码中包含的数量信息。如果条码中没有包含该种信息，则返回0。
  @poAmt decimal(24,2) output,  --条码中包含的金额信息。如果条码中没有包含该种信息，则返回0。
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare @return_status smallint
  declare @GdGid int
  declare @GdCode varchar(40)
  declare @GdName varchar(50)
  declare @Qty decimal(24,3)
  declare @RtlPrc decimal(24,4)
  declare @RtlTotal decimal(24,2)
  declare @Flag char(1)
  declare @CodeLen smallint
  declare @QtyLen smallint
  declare @AmtLen smallint
  declare @CodeType smallint

  /*
  如果一条商品条码是电子秤条码，它必定满足以下条件：
  1.首位标识码由BARCODELEN.FLAG规定；
  2.末位校验码正确；
  3.前BARCODELEN.CODELEN位=GDINPUT.CODE。
  */

  set @return_status = 1

  --条件1.首位标识码由BARCODELEN.FLAG规定
  --条件2.末位校验码正确
  if exists(select * from BARCODELEN(nolock)
    where FLAG = substring(@piBarCode, 1, 1)
    and CODELEN < len(@piBarCode)
    )
    and (dbo.RFDiscountCode_OddEvenCheck(@piBarCode) = @piBarCode
      or dbo.RFDiscountCode_OddEvenCheck2(@piBarCode) = @piBarCode
    )
  begin
    --条件2.首位标识码由BARCODELEN.FLAG规定
    declare c_BarCodeLen cursor for
      select distinct FLAG, CODELEN, QTYLEN, AMTLEN
      from BARCODELEN(nolock)
      where FLAG = substring(@piBarCode, 1, 1)
      and CODELEN < len(@piBarCode)
    open c_BarCodeLen
    fetch next from c_BarCodeLen into @Flag, @CodeLen, @QtyLen, @AmtLen
    while @@fetch_status = 0
    begin
      --解析出商品代码
      set @GdCode = substring(@piBarCode, 1, @CodeLen)

      --条件3.前BARCODELEN.CODELEN位=GDINPUT.CODE
      if exists(select * from GDINPUT(nolock) where CODE = @GdCode)
      begin
        select @GdGid = g.GID, @GdName = g.NAME,
          @RtlPrc = g.RTLPRC, @CodeType = gi.CODETYPE
          from GDINPUT gi(nolock), GOODS g(nolock)
          where gi.GID = g.GID
          and gi.CODE = @GdCode
        --金额码
        if @CodeType = 1 and len(@piBarCode) > @CodeLen + @AmtLen
        begin
          set @RtlTotal = convert(decimal(24,2), substring(@piBarCode, @CodeLen + 1, @AmtLen))
          set @RtlTotal = @RtlTotal / 100.0
          if @RtlTotal >= 0.01
          begin
            if @RtlPrc < 0.01
            begin
              set @RtlPrc = @RtlTotal
              set @Qty = 1
            end
            else begin
              set @Qty = round(@RtlTotal / @RtlPrc, 3)
            end
            set @return_status = 0
            break
          end
        end
        --数量码
        else if @CodeType = 2 and len(@piBarCode) > @CodeLen + @QtyLen
        begin
          set @Qty = convert(decimal(24,3), substring(@piBarCode, @CodeLen + 1, @QtyLen))
          set @Qty = @Qty / 1000.0
          if @Qty >= 0.001
          begin
            set @RtlTotal = round(@RtlPrc * @Qty, 2)
            set @return_status = 0
            break
          end
        end
        --数量+金额条码
        else if @CodeType = 3 and len(@piBarCode) > @CodeLen + @QtyLen + @AmtLen
        begin
          set @Qty = convert(decimal(24,3), substring(@piBarCode, @CodeLen + 1, @QtyLen))
          set @Qty = @Qty / 1000.0
          set @RtlTotal = convert(decimal(24,2), substring(@piBarCode, @CodeLen + @QtyLen + 1, @AmtLen))
          set @RtlTotal = @RtlTotal / 100.0
          if @Qty >= 0.001 and @RtlTotal >= 0.01
          begin
            set @RtlPrc = round(@RtlTotal / @Qty, 4)
            set @return_status = 0
            break
          end
        end
        --金额+数量条码
        else if @CodeType = 4 and len(@piBarCode) > @CodeLen + @QtyLen + @AmtLen
        begin
          set @RtlTotal = convert(decimal(24,2), substring(@piBarCode, @CodeLen + 1, @AmtLen))
          set @RtlTotal = @RtlTotal / 100.0
          set @Qty = convert(decimal(24,3), substring(@piBarCode, @CodeLen + @AmtLen + 1, @QtyLen))
          set @Qty = @Qty / 1000.0
          if @Qty >= 0.001 and @RtlTotal >= 0.01
          begin
            set @RtlPrc = round(@RtlTotal / @Qty, 4)
            set @return_status = 0
            break
          end
        end --codetype
      end --if exists...
      fetch next from c_BarCodeLen into @Flag, @CodeLen, @QtyLen, @AmtLen
    end
    close c_BarCodeLen
    deallocate c_BarCodeLen
  end

  if @return_status = 0
  begin
    set @poGdGid = @GdGid
    set @poQty = @Qty
    set @poAmt = @RtlTotal
    set @poErrMsg = ''
  end

  return @return_status
end
GO
