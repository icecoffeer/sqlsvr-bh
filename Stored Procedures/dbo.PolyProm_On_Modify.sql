SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_On_Modify](
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
    @Stat int
  
  /*检查*/
  set @Stat = null
  select @Stat = STAT from POLYPROM(nolock) where NUM = @Num and CLS = @Cls
  if @Stat is null
  begin
    set @Msg = '单号无效' + @Num
    return 1
  end
  
  /*按不同状态，分别操作*/
  set @return_status = 0
  if @ToStat = 0
  begin
    update POLYPROM set LSTUPDOPER = @Oper, LSTUPDTIME = GetDate() where NUM = @Num and CLS = @Cls
    exec PolyProm_AddLog @Num, @Cls, @ToStat, '修改', @Oper
  end
  else if @ToStat = 100
  begin
    exec @return_status = PolyProm_On_Modify_To100 @Num, @Cls, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 800
  begin
    exec @return_status = PolyProm_On_Modify_To800 @Num, @Cls, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 1400
  begin
    exec @return_status = PolyProm_On_Modify_To1400 @Num, @Cls, @ToStat, @Oper, @Msg output
  end
  else begin
    set @Msg = '未知的目标状态。'
    set @return_status = 1
  end
  return @return_status
end
GO
