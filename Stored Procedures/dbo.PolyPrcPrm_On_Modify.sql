SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_On_Modify](
  @Num char(14),
  @ToStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint
  set @return_status = 0
  if @ToStat = 0
  begin
    update POLYPRCPRM set LSTUPDOPER = @Oper, LSTUPDTIME = GetDate() where NUM = @Num
    exec PolyPrcPrm_AddLog @Num, @ToStat, '修改', @Oper
  end
  else if @ToStat = 100
  begin
    exec @return_status = PolyPrcPrm_On_Modify_To100 @Num, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 800
  begin
    exec @return_status = PolyPrcPrm_On_Modify_To800 @Num, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 1400
  begin
    exec @return_status = PolyPrcPrm_On_Modify_To1400 @Num, @ToStat, @Oper, @Msg output
  end
  else if @ToStat = 110
  begin
    exec @return_status = PolyPrcPrm_On_Modify_To110 @Num, @ToStat, @Oper, @Msg output
  end
  else begin
    set @Msg = '未知的目标状态。'
    set @return_status = 1
  end
  return @return_status
end
GO
