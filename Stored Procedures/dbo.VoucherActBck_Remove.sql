SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VoucherActBck_Remove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  declare @Stat smallint
  declare @return_status smallint
  
  --状态校验
  set @Stat = null
  select @Stat = STAT from VOUCHERACTBCK(nolock)
    where NUM = @Num
  if @Stat is null
  begin
    set @Msg = '单据不存在：' + @Num
    return(1)
  end
  else if @Stat <> 0
  begin
    set @Msg = '单据状态不是未审核，不能删除。'
    return(1)
  end
  
  --删除单据信息
  exec @return_status = VoucherActBck_RemoveEx @Num, @Msg output
  if @return_status <> 0
    return(@return_status)
  
  --删除日志信息
  delete from VOUCHERACTBCKLOG where NUM = @Num
  
  return(0)
end
GO
