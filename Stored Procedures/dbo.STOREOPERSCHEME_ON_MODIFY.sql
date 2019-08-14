SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[STOREOPERSCHEME_ON_MODIFY]
(
  @Num varchar(14),            --单号
  @ToStat int,                 --目标状态
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)--------------------------------------------------------
as
begin
  declare
    @vRet int,
    @FromStat int

  if @ToStat <> 0
  begin
    --状态调度
    if @tostat = 100
    begin
      exec @vRet = STOREOPERSCHEME_TO_100 @Num, @Oper, @ToStat, @Msg output
      return(@vRet)
    end
  end
  else begin
    select @FromStat = STAT from STOREOPERSCHEME(nolock) where NUM = @Num
    if @FromStat = 0
      exec STOREOPERSCHEME_ADD_LOG @Num, @ToStat, '修改', @Oper
    else
      exec STOREOPERSCHEME_ADD_LOG @Num, @ToStat, '新增', @Oper
  end
  update STOREOPERSCHEME set LSTUPDOPER = @Oper, LstUpdTime = getdate() where Num = @Num

  return(0)
end
GO
