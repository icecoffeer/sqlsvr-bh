SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_TOURCONSUME_CANCELFINISH](
  @Num varchar(14),                 --单号
  @Cls varchar(10),                 --类别
  @Oper varchar(30),                 --操作员
  @ToStat integer,                  --操作时间
  @Msg varchar(255) output          --操作人
) as
begin
  declare
    @nItemNo integer,
    @nCount integer,
    @FromStat integer    
  
  select @nCount = count(1) from ToursConsume(nolock) where Num = @Num
  if @nCount = 0 
  begin
    select @Msg = '指定单据不存在！'
    return(1)
  end 
  
  select @FromStat = Stat from ToursConsume(nolock) where Num = @Num
  
  if @FromStat <> 300 
  begin
    select @Msg = '单据不是完成状态！'
    return(1)
  end
  
  
  update ToursConsume set Stat = 100, LstUpdOper = @Oper, LstUpdTime = GetDate()    
  where Num = @Num  
  
  select @nItemNo = IsNull(Max(ItemNo), 0) + 1 from ToursConsumeLog(nolock) where Num = @Num
  insert into ToursConsumeLog(Num, ItemNo, FromStat, ToStat, Oper, OperTime)
  values(@Num, @nItemNo, 300, 100, @Oper, GetDate())  
  return(0)
end
GO
