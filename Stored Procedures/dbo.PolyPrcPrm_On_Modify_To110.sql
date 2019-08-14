SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_On_Modify_To110](  
  @Num char(14),  
  @ToStat int,  
  @Oper varchar(30),  
  @Msg varchar(255) output  
)  
as  
begin  
  declare  
    @return_status smallint,  
    @Present datetime,  
    @Stat int  
  set @Present = GetDate()  
  select @Stat = STAT from POLYPRCPRM(nolock) where NUM = @Num  
  if @Stat <> 100 --已审核的单据才能作废 edit by qzh CSTPRO-1110
  begin  
    set @Msg = '不是已审核的单据，不能作废。'  
    return 1  
  end  
  update POLYPRCPRM  
    set STAT = @ToStat, LSTUPDOPER = @Oper, LSTUPDTIME = @Present  
    where NUM = @Num  
  delete from POLYPRCPRMOCR where BILLNUM = @Num  
  delete from POLYPRCPRMEXGDDTLOCR where BILLNUM = @Num  
  --清除促销单优先级数据  
  exec @return_status = PS3_DelPromPir '单品', '批量价格促销', @Num  
  if @return_status <> 0  
    return @return_status  
  exec PolyPrcPrm_AddLog @Num, @ToStat, '作废', @Oper  
  
  return 0  
end  
GO
