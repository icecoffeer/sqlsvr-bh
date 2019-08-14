SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3SPECSCOPESCORE_ON_MODIFY]
(
  @Num varchar(14),            --单号
  @Cls varchar(10),            --类型
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)   --------------------------------------------------------
as
begin
  declare
    @return_status int

  set @return_status = 0
  if @ToStat = 0
  begin
    update PS3SPECSCOPESCORE set
      LSTUPDOPER = @Oper,
      LstUpdTime = getdate()
      where Num = @Num
      and CLS = @Cls
    exec PS3SPECSCOPESCORE_ADD_LOG @Num, @Cls, @ToStat, '修改', @Oper
  end
  else if @ToStat = 100
  begin
    exec @return_status = PS3SPECSCOPESCORE_CHECK  @Num, @Cls, @Oper, @ToStat, @Msg output
  end
  else begin
    set @Msg = '未定义的目标状态：' + convert(varchar, @ToStat) + '。'
    set @return_status = 1
  end
  return(@return_status)
end
GO
