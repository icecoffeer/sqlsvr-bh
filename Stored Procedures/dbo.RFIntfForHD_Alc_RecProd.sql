SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alc_RecProd]
(
  @piPDANum varchar(40),           --PDA编号
  @piEmpCode varchar(10),          --员工代码
  @piGdGid int,                    --商品id
  @piScanQty money,                --扫描商品数量
  @poErrMsg varchar(255) output    --返回错误信息，当返回值不等于0时有效
)
as
begin
  if exists (select 1 from RF_RECGOODS(nolock)
    where GDGID = @piGdGid
    and EMPCODE = @piEmpCode
    and PDANUM = @piPDANum)
  begin
    update RF_RECGOODS set
      RECQTY = RECQTY + @piScanQty
      where GDGID = @piGdGid
      and EMPCODE = @piEmpCode
      and PDANUM = @piPDANum
  end
  else begin
    insert into RF_RECGOODS(GDGID, RECQTY, EMPCODE, PDANUM)
      values(@piGdGid, @piScanQty, @piEmpCode, @piPDANum)
  end
  if @@error <> 0
  begin
    set @poErrMsg = '更新配货收货表错误'
    return(1)
  end

  return(0)
end
GO
