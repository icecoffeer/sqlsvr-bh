SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_On_Modify_To100](
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
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能审核。'
    return 1
  end
  
  /*更新汇总信息*/
  update POLYPROM
    set STAT = @ToStat, LSTUPDOPER = @Oper, LSTUPDTIME = @Present,
      CHECKER = @Oper, CHKDATE = @Present
    where NUM = @Num and CLS = @Cls
  
  /*日志*/
  exec PolyProm_AddLog @Num, @Cls, @ToStat, '审核', @Oper

  /*生效*/
  exec @return_status = PolyProm_On_Modify_To800 @Num, @Cls, 800, @Oper, @Msg output
  if @return_status <> 0 return @return_status
  
  return 0
end
GO
