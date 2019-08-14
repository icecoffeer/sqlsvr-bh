SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_UpdStock](
  @piEmpCode varchar(10),
  @piWrhCode varchar(10),
  @piSubWrh varchar(64),
  @piArticleCode varchar(40),
  @piQtyStr varchar(50), --整件数+单品数
  @piPDANum varchar(40),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @vEmpGid int,
    @vWrhGid int,
    @vArticleGid int,
    @vIsLtd int,
    @vGdQpc decimal(24,4),
    @vQty decimal(24,4),
    @vUUID varchar(32),
    @vBarCodeQty decimal(24,4),
    @vBarCodeAmt decimal(24,2),
    @optMaxQtyStr varchar(100),
    @optMaxQtyDec decimal(24,4),
    @optCanCheckClearGoods int

  --获取员工GID

  select @vEmpGid = GID
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode

  --获取仓位GID

  select @vWrhGid = GID
    from WAREHOUSE(nolock)
    where CODE = @piWrhCode

  --获取货品GID

  exec @return_status = RFIntfForHD_GetGoods
    @piArticleCode, @vArticleGid output, @vBarCodeQty output, @vBarCodeAmt output, @poErrMsg output
  if @return_status <> 0
    return 1

  --获取选项的值

  exec OptReadStr 8146, 'CKMAXQTY', '0', @optMaxQtyStr output
  set @optMaxQtyDec = convert(money, IsNull(@optMaxQtyStr, '')) --空字符转换成MONEY型，会变成0
  exec OptReadInt 8146, 'Inv_Ck_Can_Check_Clear_Goods', '0', @optCanCheckClearGoods output

  --检查是否清场品

  if @optCanCheckClearGoods = 0
  begin
    select @vIsLtd = ISLTD from GOODS(nolock) where GID = @vArticleGid
    if @vIsLtd & 8 = 8
    begin
      set @poErrMsg = '商品是清场品，不能盘点。'
      return 1
    end
  end

  --计算本次收货数量

  select @vGdQpc = QPC from GOODS(nolock) where GID = @vArticleGid
  set @vQty = dbo.StrToQty(@piQtyStr, @vGdQpc)

  --检查数量

  if @vQty = 0
  begin
    return 0
  end
  if @optMaxQtyDec <> 0 and @vQty > @optMaxQtyDec
  begin
    set @poErrMsg = '数量大于单次盘点上限' + @optMaxQtyStr
    return 1
  end

  --插入记录

  if exists(select * from RFPCK(nolock)
    where FILLER = @vEmpGid
      and WRH = @vWrhGid
      and SUBWRH = isnull(@piSubWrh, '')
      and GDGID = @vArticleGid
      and PDANUM = @piPDANum
  )
  begin
    update RFPCK set QTY = QTY + @vQty, LSTUPDTIME = GetDate()
      where FILLER = @vEmpGid
        and WRH = @vWrhGid
        and SUBWRH = isnull(@piSubWrh, '')
        and GDGID = @vArticleGid
        and PDANUM = @piPDANum
  end
  else begin
    exec HD_CREATEUUID @vUUID output
    insert into RFPCK(UUID, FILLER, WRH, GDGID, QTY, FILDATE, LSTUPDTIME,
      NOTE, SUBWRH, PDANUM)
      values(@vUUID, @vEmpGid, @vWrhGid, @vArticleGid, @vQty, GetDate(), GetDate(),
      null, isnull(@piSubWrh, ''), @piPDANum)
  end

  return 0
end
GO
