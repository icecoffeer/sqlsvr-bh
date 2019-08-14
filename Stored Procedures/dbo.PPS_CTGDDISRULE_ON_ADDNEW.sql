SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_CTGDDISRULE_ON_ADDNEW] (
  @piUUID varchar(32), 
  @piOper varchar(30),
  @poErrMsg varchar(255) output       --出错信息
)as
begin
  declare
    @vUUID varchar(32),
    @vPreUUID varchar(32),
    @vCardType varchar(20),
    @vGDGid integer,
    @vGDQpc integer,
    @vDisCount decimal(24, 2),
    @vExDis integer,
    @vBeginDate datetime,
    @vEndDate datetime,
    @vLine integer,
    @vUpdBeginDate datetime,
    @vUpdEndDate datetime,
    @vPreEndDate datetime

 

  ---读取新增加消费规则信息
  select @vCardType = CardType, @vGDGid = GDGid, @vGDQpc = GDQpc, @vBeginDate =  BeginDate, @vDisCount = DisCount, @vExDis = ExDis
  from PSCTGDDisRule(nolock) where UUID = @piUUID

  ---记录日志
  insert into PSCTGDDisRuleLog(CardType, GDGid, GDQpc, Note, Oper, Opertime)
  values(@vCardType, @vGDGid, @vGDQpc, SubString('增加折扣率为: ' + convert(varchar(10), @vDisCount) + ' 折扣规则。开始日期：' + convert(varchar(10), @vBeginDate, 102), 1, 255),  @piOper,  getdate())

  ---删除当天重复修改的数据
  declare curDelData cursor for
    select UUID
    from PSCTGDDisRule(nolock)
    where CardType = @vCardType and GDGid = @vGDGid and GDQpc = @vGDQpc and convert(varchar(10), BeginDate, 102) = convert(varchar(10), @vBeginDate, 102) and UUID <> @piUUID
    order by BeginDate
 
  ---删除当天重复修改数据
  open curDelData 
  fetch next from curDelData into @vUUID
  while @@fetch_status = 0 
  begin    
    insert into PSCTGDDisRuleLog(CardType, GDGid, GDQpc, Note, Oper, OperTime)
    select CardType, GDGid, GDQpc, Substring('删除当天重复修改折扣率为：' + convert(varchar(10), DisCount) + '特许折扣为：' + case when ExDis = 1 then '是' else '否'end , 1, 255), @piOper, getDate()
    from PSCTGDDisRule(nolock)
    where UUID = @vUUID
    delete from PSCTGDDisRule where UUID = @vUUID
    fetch next from curDelData into @vUUID
  end
  close curDelData
  deallocate curDelData

  ---更改以前的结束日期
  declare curUpdData cursor for
    select UUID, BeginDate, EndDate
    from PSCTGDDisRule(nolock)
    where CardType = @vCardType and GDGid = @vGDGid and GDQpc = @vGDQpc
    order by BeginDate    

  --修改结束日期
  select @vLine = 0
  open curUpdData 
  fetch next from curUpdData into @vUUID, @vUpdBeginDate, @vUpdEndDate
  while @@fetch_status = 0 
  begin
    select @vLine = @vLine + 1
    if (@vLine <> 1) and (convert(varchar(10), @vPreEndDate, 102) <> convert(varchar(10), @vUpdBeginDate - 1, 102))
    begin
      update PSCTGDDisRule set EndDate = convert(varchar(10), @vUpdBeginDate - 1, 102) where UUID = @vPreUUID
    end      
    select @vPreUUID = @vUUID
    select @vPreEndDate = @vUpdEndDate
    fetch next from curUpdData into @vUUID, @vUpdBeginDate, @vUpdEndDate 
  end
  close curUpdData
  deallocate curUpdData 
  return(0);  
end 
GO
