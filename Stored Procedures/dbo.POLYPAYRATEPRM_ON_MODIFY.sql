SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[POLYPAYRATEPRM_ON_MODIFY]  
(  
  @Num varchar(14),            --单号  
  @Cls varchar(10),  
  @ToStat int,                 --目标状态  
  @Oper varchar(30),           --操作人  
  @Msg varchar(255) output  --错误信息  
)   --------------------------------------------------------  
as  
begin  
  declare @vRet int, @FromStat int;  
  
  if @ToStat <> 0  
  begin  
   --状态调度  
     if @tostat = 800  
     begin  
       exec @vRet = POLYPAYRATEPRM_CHECK  @Num, @Cls, @Oper, @ToStat, @Msg output;  
       return(@vRet)  
     end  
  end  
  else begin  
    select @FromStat = STAT from POLYPAYRATEPRM(nolock) where NUM = @Num and CLS = @Cls;  
    if @FromStat = 0  
      exec POLYPAYRATEPRM_ADD_LOG @Num, @Cls, @ToStat, '修改', @Oper;  
    else  
      exec POLYPAYRATEPRM_ADD_LOG @Num, @Cls, @ToStat, '新增', @Oper;  
  end;  
  update POLYPAYRATEPRM set LSTUPDOPER = @Oper, LstUpdTime = getdate() where Num = @Num and CLS = @Cls;  
  return(0)  
end  
GO
