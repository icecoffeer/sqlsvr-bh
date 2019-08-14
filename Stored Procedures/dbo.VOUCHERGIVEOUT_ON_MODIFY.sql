SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[VOUCHERGIVEOUT_ON_MODIFY]
(
  @Num varchar(14),            --单号
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)   --------------------------------------------------------
as
begin
  declare @vRet int, @FromStat int
  if @ToStat = 100
  begin
   --状态调度
     exec @vRet = VOUCHERGIVEOUT_CHKTO100 @Num, @Oper, @Msg output
     return(@vRet)
  end else
  begin
    select @FromStat = STAT from VOUCHERGIVE(nolock) where NUM = @Num
    if @FromStat = 0
      exec VOUCHERGIVEOUT_ADD_LOG @Num, @ToStat, '修改', @Oper
    else
      exec VOUCHERGIVEOUT_ADD_LOG @Num, @ToStat, '新增', @Oper
  end
  update VOUCHERGIVE set LSTUPDOPER = @Oper, LstUpdTime = getdate() where Num = @Num

  return(0)
end
GO
