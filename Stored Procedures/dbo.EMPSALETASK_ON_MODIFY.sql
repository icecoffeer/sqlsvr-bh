SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[EMPSALETASK_ON_MODIFY]
(
  @Num varchar(14),         --单号
  @ToStat int,              --目标状态
  @Oper varchar(30),        --操作人
  @Msg varchar(255) output  --错误信息
)   --------------------------------------------------------
as
begin
  declare @vRet int, @FromStat int;
  if @ToStat = 0
  begin
    select @FromStat = STAT from EMPSALETASK(nolock) where NUM = @Num
    if @FromStat = 0
      exec EMPSALETASK_ADD_LOG @Num, @ToStat, '修改', @Oper;
    else
      exec EMPSALETASK_ADD_LOG @Num, @ToStat, '新增', @Oper;
    update EMPSALETASK set LSTUPDOPER = @Oper, LstUpdTime = getdate() where Num = @Num
    return(0)
  end
  else if @ToStat = 100
  begin
    exec @vRet = EMPSALETASK_MODIFYTO100 @Num, @Oper, @ToStat, @Msg output;
    return(@vRet)
  end
  else if @ToStat = 110
  begin
    exec @vRet = EMPSALETASK_MODIFYTO110 @Num, @Oper, @ToStat, @Msg output;
    return(@vRet)
  end
end
GO
