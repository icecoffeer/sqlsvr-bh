SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_On_Modify_To1400](  
  @Num char(14),  
  @Cls char(10),  
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
  
  /*常用变量*/  
  set @Present = GetDate()  
  
  /*检查*/  
  select @Stat = STAT from POLYPROM(nolock) where NUM = @Num and CLS = @Cls  
  if @Stat <> 800 --已生效的单据才能终止 edit by qzh CSTPRO-1110  
  begin  
    set @Msg = '不是已生效的单据，不能终止。'  
    return 1  
  end  
  
  /*更新汇总信息*/  
  update POLYPROM  
    set STAT = @ToStat, LSTUPDOPER = @Oper, LSTUPDTIME = @Present  
    where NUM = @Num and CLS = @Cls  
  
  /*更新当前值表*/  
  update POLYPROMOCR  
    set AFINISH = @Present  
    where CLS = @Cls and BILLNUM = @Num  
      and AFINISH > @Present  
  
  --清除促销单优先级数据  
  declare @PrmName Char(30)  
  Set @PrmName = '批量' + @Cls + '促销'  
  exec @return_status = PS3_DelPromPir '组合', @PrmName, @Num  
  if @return_status <> 0  
    return @return_status  
  
  /*日志*/  
  exec PolyProm_AddLog @Num, @Cls, @ToStat, '终止', @Oper  
  
  return 0  
end  
GO
