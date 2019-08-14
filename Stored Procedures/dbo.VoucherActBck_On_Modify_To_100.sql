SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VoucherActBck_On_Modify_To_100](
  @Num char(14),
  @Oper varchar(30),
  @Msg varchar(255) output
)
as
begin
  declare @return_status smallint
  declare @Stat smallint
  
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
    set @Msg = '单据状态不是未审核，不能进行审核操作。'
    return(1)
  end
  
  --更新汇总信息
  update VOUCHERACTBCK set
    STAT = 100,
    LSTUPDTIME = getdate(),
    LSTUPDOPER = @Oper,
    CHKDATE = getdate(),
    CHECKER = @Oper
    where NUM = @Num

  --记录日志
  exec VoucherActBck_AddLog @Num, 100, @Oper, null

  return(0)
end
GO
