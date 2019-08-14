SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POLYPAYRATEPRM_ABORT]  
(  
  @num      varchar(14),  
  @cls      varchar(10),  
  @oper     varchar(30),  
  @tostat   int,  
  @msg  varchar(255) output  
)  
as  
begin  
  declare  
    @stat int  
  
  select @stat = stat from POLYPAYRATEPRM(nolock) where num = @num and cls = @cls  
  if @stat <> 800  
  begin  
    set @msg = '目标状态不对' + ltrim(str(@stat))  
    return 1  
  end  
  
  if @Cls = '批量联销率'  
    delete from POLYPAYRATEPRICE  
      where BILLNUM = @num and CLS = @cls  
  else if @Cls = '商品折扣'  
    delete from DISRATEAGMINV  
      where NUM = @num and CLS = @cls  
  
  update POLYPAYRATEPRM set STAT = 1400, LSTUPDTIME = getdate(), LSTUPDOPER = @oper  
    where num = @num and cls = @cls  
  exec POLYPAYRATEPRM_ADD_LOG @Num, @Cls, @ToStat, '终止', @Oper  
  
  return 0  
end  
GO
