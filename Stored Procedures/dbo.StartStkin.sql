SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[StartStkin](
  @piEmpCode varchar(10),            --传入参数：操作员代码。
  @piOrdNum varchar(14),             --传入参数：定单号(10位，或14位且前4位为本店代码)或定单来源单号(14位且前4位为其他门店代码)。
  @poLocalOrdNum varchar(10) output, --传出参数（返回值为0时有效）：本地定单号(10位，对应于ORD.NUM)。
  @poGRNum varchar(14) output,       --传出参数（返回值为0时有效）：收货单号。
  @poNote varchar(255) output,       --传出参数（返回值为0时有效）：备注，如订单状态（已审核，进行中，已完成）。
  @poErrMsg varchar(255) output      --传出参数（返回值不为0时有效）：错误消息。
) as
begin
  declare
    @Ret int,
    @UserGid int, --本店GID
    @EmpGid int, --收货人GID
    @OrdStat int, --定单状态
    @OrdFinished int, --定单完成状态
    @OrdReceiver int --定单要货单位

  --系统设定
  select @UserGid = USERGID from SYSTEM(nolock)

  --操作人
  select @EmpGid = GID
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode;
  if @@rowcount = 0
  begin
    select @poErrMsg = '操作员代码 ' + rtrim(@piEmpCode) + ' 无效。'
    return(1)
  end

  --解析传入单号。
  exec @Ret = RFIntfForHD_OrdStkin_ParseNum @piOrdNum, @poLocalOrdNum output, @poErrMsg output
  if @Ret <> 0
    return(1)

  --校验定单号。
  select @OrdStat = STAT, @OrdFinished = FINISHED, @OrdReceiver = RECEIVER
    from ORD(nolock)
    where NUM = @poLocalOrdNum
  if @@rowcount = 0
  begin
    select @poErrMsg = '定单号 ' + rtrim(@poLocalOrdNum) + ' 无效。'
    return(1)
  end
  if @OrdStat <> 1
  begin
    select @poErrMsg = '定单 ' + rtrim(@poLocalOrdNum) + ' 不是已审核状态，不能收货。'
    return(1)
  end
  if @OrdFinished = 1
  begin
    select @poErrMsg = '定单 ' + rtrim(@poLocalOrdNum) + ' 是已结束状态，不能收货。'
    return(1)
  end
  if @OrdReceiver <> @UserGid
  begin
    select @poErrMsg = '定单 ' + rtrim(@poLocalOrdNum) + ' 的要货单位不是本店，不能收货。'
    return(1)
  end

  --查找符合条件的收货单，找到则正常返回，否则生成新收货单。
  select top 1 @poGRNum = NUM
    from GOODSRECEIPT(nolock)
    where STAT = 0 --状态：未审核
    and RECEIVER = @EmpGid --收货人：当前操作人
    and SRCORDNUM = @poLocalOrdNum --定货单号：当前定货单号
    order by NUM desc
  if @@rowcount > 0
  begin
    select @poNote = '收货状态：进行中'
    return(0)
  end

  --生成收货单。
  exec @Ret = RFIntfForHD_OrdStkin_GenGR @EmpGid, @poLocalOrdNum, @poGRNum output, @poErrMsg output
  if @Ret <> 0
    return(1)

  return(0)
end
GO
