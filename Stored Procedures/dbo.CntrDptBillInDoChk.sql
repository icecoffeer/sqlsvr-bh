SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[CntrDptBillInDoChk] (
  @num char(14)
)
as
begin
  declare @vendor int,
    @total money
  select @vendor = vendor, @total = total from cntrdptbill(nolock)
  where cls = '收' and num = @num
  
  if not exists(select 1 from cntrdpt(nolock) where vendor = @vendor)
    insert into cntrdpt(vendor, total, lstupdtime, lstupdcls, lstupdnum)
    values(@vendor, @total, getdate(), '压库金额收款单', @num)
  else
    update cntrdpt set 
      total = total + @total,
      lstupdtime = getdate(),
      lstupdcls = '压库金额付款单',
      lstupdnum = @num
    where vendor = @vendor
end
GO
