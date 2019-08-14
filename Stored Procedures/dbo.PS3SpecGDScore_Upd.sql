SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SpecGDScore_Upd]
(
  @Num varchar(14),            --单号
  @Cls varchar(10),            --类型
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息 
)
as
begin
	  declare
    @return_status int,
    @old_num char(14),
    @old_stat int,
    @new_num char(14)

  set @new_num = @Num
  select @old_num = MODNUM from PS3SPECGDSCORE(nolock) where NUM = @new_num
  select @return_status = 0

  select @old_stat = STAT from PS3SPECGDSCORE(nolock) where NUM = @old_num
  if (@old_stat <> 100)
  begin
    set @Msg = '被修正的单据不是已审核状态.'
    return(1)
  end

  --审核新单据
  update PS3SPECGDSCORE set stat = 0 where num = @new_num
  execute @return_status = PS3SPECGDSCORE_ON_MODIFY @new_num, @Cls, 100, @Oper, @Msg output 
  if @return_status <> 0
  begin
    return @return_status
    set @Msg = '审核修正单出错'
  end
  --作废旧单据
  execute @return_status = PS3SPECGDSCORE_ABORT @old_num, @Cls, @Oper, 910, @MSG output
  if @return_status <> 0
  begin
    return @return_status
    set @Msg = '修改被修正单据状态出错'
  end
  update PS3SPECGDSCORE set note = '修正后的单据'+@new_num where num = @old_num

  return @return_status
end	
GO
