SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InternalTransfer_AddGoods](
  @piOperationType char(10),
  @piOperatorCode char(10),
  @piRFNo char(10),
  @piFromWrhCode char(10),
  @piToWrhCode char(10),
  @piGdCode char(13),
  @piQty decimal(24,4),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @Cnt int

  select @piOperationType = isnull(@piOperationType, ''),
    @piOperatorCode = isnull(@piOperatorCode, ''),
    @piRFNo = isnull(@piRFNo, ''),
    @piFromWrhCode = isnull(@piFromWrhCode, ''),
    @piToWrhCode = isnull(@piToWrhCode, ''),
    @piGdCode = isnull(@piGdCode, ''),
    @piQty = isnull(@piQty, 0)

  if rtrim(@piOperationType) not in ('调出', '调入')
  begin
    set @poErrMsg = '未定义的操作类型：' + rtrim(@piOperationType)
    return 1
  end

  if not exists(select * from EMPLOYEE(nolock) where CODE = @piOperatorCode)
  begin
    set @poErrMsg = '员工代码 ' + rtrim(@piOperatorCode) + ' 无效。'
    return 1
  end

  if not exists(select * from WAREHOUSE(nolock) where CODE = @piFromWrhCode)
  begin
    set @poErrMsg = '调出仓位代码 ' + rtrim(@piFromWrhCode) + ' 无效。'
    return 1
  end

  if not exists(select * from WAREHOUSE(nolock) where CODE = @piToWrhCode)
  begin
    set @poErrMsg = '调入仓位代码 ' + rtrim(@piToWrhCode) + ' 无效。'
    return 1
  end

  if rtrim(@piFromWrhCode) = rtrim(@piToWrhCode)
  begin
    set @poErrMsg = '调出和调入仓位不能相同。'
    return 1
  end

  select @Cnt = count(*) from STORE s(nolock), WAREHOUSE w(nolock)
    where s.GID = w.GID
    and w.CODE in (rtrim(@piFromWrhCode), rtrim(@piToWrhCode))
  if @Cnt not in (0, 2)
  begin
    set @poErrMsg = '调出和调入仓位必须同时为门店或仓位。'
    return 1
  end

  if not exists(select * from GOODS(nolock) where CODE = @piGdCode)
  begin
    set @poErrMsg = '商品代码 ' + rtrim(@piGdCode) + ' 无效。'
    return 1
  end

  insert into RFXF(UUID, OPERATIONTYPE, OPERATORCODE, OPERATIONTIME,
    RFNO, FROMWRHCODE, TOWRHCODE, GDCODE,
    QTY, GENBILLNAME, GENBILLNUM, GENTIME)
    values(newid(), @piOperationType, @piOperatorCode, getdate(),
    @piRFNo, @piFromWrhCode, @piToWrhCode, @piGdCode,
    @piQty, null, null, null)

  return 0
end
GO
