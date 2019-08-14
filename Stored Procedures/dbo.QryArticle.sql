SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[QryArticle](
  @piEmpCode varchar(10),               --员工代码
  @piWrhCode varchar(10),               --仓位代码
  @piArticleCode varchar(40),           --货品代码
  @poErrMsg varchar(255) output         --错误信息
)
as
begin
  declare
    --一般变量
    @return_status int,
    @vUserGid int,
    @vEmpGid int,
    @vWrhGid int,
    @vFilDate datetime,
    @vSQL nvarchar(1024),
    @vParams nvarchar(1024),
    --商品信息
    @vArticleGid int,
    @vArticleName varchar(50),
    @vBillTo int,
    @vSpec varchar(40),
    @vMUnit varchar(6),
    @vRtlPrc decimal(24,4),
    @vPrmRtlPrc decimal(24,4),
    @vInPrc decimal(24,4),
    @vCntInPrc decimal(24,4),
    @vPrmInPrc decimal(24,4),
    @vInvQty decimal(24,4),
    @vOrdQty decimal(24,4),
    @vInvInPrcTotal decimal(24,2),
    @vPrmRtlStart datetime,
    @vPrmRtlFinish datetime,
    @vPrmInStart datetime,
    @vPrmInFinish datetime,
    @vOrigin varchar(20),
    @vGrade varchar(20),
    @vBrandName varchar(40),
    @vMbrPrc decimal(24,4),
    @vQpc decimal(24,4),
    @vBarCodeQty decimal(24,4),
    @vBarCodeAmt decimal(24,2),
    --权限
    @vInvQtyRight char(1),
    @vOrdQtyRight char(1),
    @vInPrcRight char(1),
    --返回值
    @vInvQtyChar varchar(100),
    @vOrdQtyChar varchar(100),
    @vInPrcChar varchar(100),
    @vCntInPrcChar varchar(100),
    @vPrmInPrcChar varchar(100),
    @vPrmInStartChar varchar(100),
    @vPrmInFinishChar varchar(100),
    @vInvInPrcTotalChar varchar(100)

  --公共变量初始化

  select @vUserGid = USERGID from SYSTEM(nolock)
  select @vEmpGid = GID from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  set @vFilDate = GetDate()

  --仓位条件为选填

  if IsNull(@piWrhCode, '') <> ''
  begin
    select @vWrhGid = GID from WAREHOUSE(nolock)
      where CODE = @piWrhCode
    if @@rowcount = 0
    begin
      set @poErrMsg = '仓位代码无效。'
      return 1
    end
  end
  else begin
    set @vWrhGid = -1
  end

  --解析条码，获取商品GID

  exec @return_status = RFIntfForHD_GetGoods
    @piArticleCode, @vArticleGid output, @vBarCodeQty output, @vBarCodeAmt output, @poErrMsg output
  if @return_status <> 0
    return 1

  --货品信息

  select @vArticleName = g.NAME,
    @vBillTo = g.BILLTO,
    @vSpec = g.SPEC,
    @vMUnit = g.MUNIT,
    @vRtlPrc = g.RTLPRC,
    @vCntInPrc = g.CNTINPRC,
    @vOrigin = g.ORIGIN,
    @vGrade = g.GRADE,
    @vBrandName = b.NAME,
    @vMbrPrc = g.MBRPRC,
    @vQpc = g.QPC
    from GOODS g(nolock)
      left join BRAND b(nolock) on g.BRAND = b.CODE
    where g.GID = @vArticleGid

  --促销售价

  exec GetGoodsPrmPrcEx @vUserGid, @vArticleGid, @vFilDate, 1, '1*1',
    @vPrmRtlPrc output, @vPrmRtlStart output, @vPrmRtlFinish output
  if @vPrmRtlPrc = @vRtlPrc
  begin
    set @vPrmRtlPrc = null
    set @vPrmRtlStart = null
    set @vPrmRtlFinish = null
  end

  --核算进价

  exec GetGoodsInPrc @vArticleGid, @vWrhGid, @vInPrc output

  --促销进价

  exec @return_status = GetGoodsPrmStkInPrcEx @vBillTo, @vUserGid, @vArticleGid,
    @vPrmInPrc output, @vPrmInStart output, @vPrmInFinish output
  if @return_status <> 0
  begin
    set @vPrmInPrc = null
    set @vPrmInPrc = null
    set @vPrmInPrc = null
  end

  --库存信息

  set @vInvQty = 0
  set @vOrdQty = 0
  set @vSQL = 'select  @vInvQty = IsNull(sum(QTY), 0),'
    + ' @vOrdQty = IsNull(sum(ORDQTY), 0)'
    + ' from INV(nolock)'
    + ' where GDGID = @vArticleGid'
    + ' and STORE = @vUserGid'
  if @vWrhGid <> -1
    set @vSQL = @vSQL + ' and WRH = @vWrhGid'
  set @vParams = '@vInvQty decimal(24,4) output,'
    + ' @vOrdQty decimal(24,4) output,'
    + ' @vArticleGid int,'
    + ' @vUserGid int'
  if @vWrhGid <> -1
    set @vParams = @vParams + ',@vWrhGid int'
  if @vWrhGid <> -1
    exec SP_EXECUTESQL @vSQL, @vParams, @vInvQty output, @vOrdQty output, @vArticleGid, @vUserGid, @vWrhGid
  else
    exec SP_EXECUTESQL @vSQL, @vParams, @vInvQty output, @vOrdQty output, @vArticleGid, @vUserGid

  --库存额

  set @vInvInPrcTotal = @vInPrc * @vInvQty

  --一些信息需根据权限展示

  exec RFIntfForHD_GetSpecRight @vEmpGid, 8146004, '-', @vInvQtyRight output
  exec RFIntfForHD_GetSpecRight @vEmpGid, 8146005, '-', @vOrdQtyRight output
  exec RFIntfForHD_GetSpecRight @vEmpGid, 8146006, '-', @vInPrcRight output

  if @vInvQtyRight <> '0'
  begin
    set @vInvQtyChar = '无查看权'
    set @vInvInPrcTotalChar = '无查看权'
  end
  else begin
    set @vInvQtyChar = convert(varchar, @vInvQty)
    set @vInvInPrcTotalChar = convert(varchar, @vInvInPrcTotal)
  end

  if @vOrdQtyRight <> '0'
  begin
    set @vOrdQtyChar = '无查看权'
  end
  else begin
    set @vOrdQtyChar = convert(varchar, @vOrdQty)
  end

  if @vInPrcRight <> '0'
  begin
    set @vInPrcChar = '无查看权'
    set @vCntInPrcChar = '无查看权'
    set @vPrmInPrcChar = '无查看权'
    set @vPrmInStartChar = '无查看权'
    set @vPrmInFinishChar = '无查看权'
  end
  else begin
    set @vInPrcChar = convert(varchar, @vInPrc)
    set @vCntInPrcChar = convert(varchar, @vCntInPrc)
    set @vPrmInPrcChar = convert(varchar, @vPrmInPrc)
    set @vPrmInStartChar = convert(varchar, @vPrmInStart, 20)
    set @vPrmInFinishChar = convert(varchar, @vPrmInFinish, 20)
  end

  --返回结果集

  select @vArticleName 货品名称,
    @vSpec 规格,
    @vMUnit 计量单位,
    @vRtlPrc 核算售价,
    @vPrmRtlPrc 促销售价,
    convert(varchar, @vPrmRtlStart, 20) 促销售价开始时间,
    convert(varchar, @vPrmRtlFinish, 20) 促销售价结束时间,
    @vInPrcChar 核算进价,
    @vCntInPrcChar 合同进价,
    @vPrmInPrcChar 促销进价,
    @vPrmInStartChar 促销进价开始时间,
    @vPrmInFinishChar 促销进价结束时间,
    @vInvQtyChar 库存数,
    @vInvInPrcTotalChar 库存额,
    @vOrdQtyChar 在单量,
    @vOrigin 产地,
    @vGrade 等级,
    @vBrandName 品牌,
    @vMbrPrc 会员价,
    @vQpc 包装规格
  return 0
end
GO
