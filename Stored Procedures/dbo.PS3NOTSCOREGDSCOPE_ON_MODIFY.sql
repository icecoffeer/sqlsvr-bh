SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3NOTSCOREGDSCOPE_ON_MODIFY]
(
  @Num varchar(14),            --单号
  @Cls varchar(10),            --类型
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)   --------------------------------------------------------
as
begin
  declare @vRet int, @FromStat int

  if @ToStat <> 0
  begin
   --状态调度
     if @tostat = 100
     begin
       exec @vRet = PS3NOTSCOREGDSCOPE_CHECK  @Num, @Cls, @Oper, @ToStat, @Msg output
       return(@vRet)
     end
  end
  else begin
    select @FromStat = STAT from PS3NOTSCOREGDSCOPE(nolock) where NUM = @Num and CLS = @Cls
    if @FromStat = 0
      exec PS3NOTSCOREGDSCOPE_ADD_LOG @Num, @Cls, @ToStat, '修改', @Oper
    else
      exec PS3NOTSCOREGDSCOPE_ADD_LOG @Num, @Cls, @ToStat, '新增', @Oper
  end
  update PS3NOTSCOREGDSCOPE set LSTUPDOPER = @Oper, LstUpdTime = getdate() where Num = @Num and CLS = @Cls
  return(0)
end
GO
