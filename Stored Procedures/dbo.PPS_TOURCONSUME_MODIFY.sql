SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_TOURCONSUME_MODIFY](
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
    @FromStat integer,
    @CardNum varchar(20)
  
  select @nCount = count(1) from ToursConsume(nolock) where Num = @Num
  if @nCount = 0 
  begin
    select @Msg = '指定单据不存在！'
    return(1)
  end 
  
  select @FromStat = Stat, @CardNum = CardNum from ToursConsume(nolock) where Num = @Num
  
  if @ToStat = 100 
  begin     
    if @FromStat <> 0
    begin
      select @Msg = '单据状态不是未审核，不能审核！'
      return(1)
    end
    select @nCount = count(1) from ToursConsume(nolock) where Num <> @Num and CardNum = @CardNum and Stat = 100
    if @nCount > 0 
    begin
      select @Msg = '存在已审核的会员卡号是' + @CardNum +  ' 的团队消费数据'
      return(1)
    end

    update ToursConsume set Stat = 100, Checker = @Oper, ChkDate = GetDate(), LstUpdOper = @Oper, LstUpdTime = GetDate() where Num = @Num
  end   
  if @ToStat = 300 
  begin
    if @FromStat <> 100
    begin
      select @Msg = '单据状态不是审核，不能完成！'
      return(1)
    end
    
    select @nCount = count(1) from ToursConsumeDtl(nolock) where Num = @Num
    if @nCount = 0 
    begin
      select @Msg = '指定单据明细为空！'
      return(1)
    end 
    update ToursConsume set Stat = 300, LstUpdOper = @Oper, LstUpdTime = GetDate() where Num = @Num
  end   

  select @nItemNo = IsNull(Max(ItemNo), 0) + 1 from ToursConsumeLog(nolock) where Num = @Num
  
  insert into ToursConsumeLog(Num, ItemNo, FromStat, ToStat, Oper, OperTime)
  values(@Num, @nItemNo, @FromStat, @ToStat, @Oper, GetDate())  
  return(0)
end
GO
