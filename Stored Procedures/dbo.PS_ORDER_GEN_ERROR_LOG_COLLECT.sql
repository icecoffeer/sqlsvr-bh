SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure  [dbo].[PS_ORDER_GEN_ERROR_LOG_COLLECT]
(
  @piStartDate datetime,  
  @piEndDate datetime ,
  @poErrMsg varchar(255) output
)
as
begin
  -- 有通知无批发单的情况单据
  insert into PSOnlineOrdGenErrorLog(ordno,ordfildate,note,billfrom,GenBillName)
  select distinct businesskey, ntime, null, null, '批发单'
  from PSUPOWERNOTIFICATION b(nolock)
  where ntime >= @piStartDate and ntime < @piEndDate
  and topic = 'store.order.shipped'
  and businesskey is not null
  and not exists(select 1 from PS3_OnLineOrdGenBills  c(nolock) where c.genbillname = '批发单' and b.businesskey = c.ordno)
  and not exists(select 1 from PSOnlineOrdGenErrorLog ErrLog(nolock) where b.businesskey = ErrLog.ordno)
  
  
  insert into PSOnlineOrdGenErrorLog(ordno,ordfildate,note,billfrom,GenBillName)
  select distinct businesskey,ntime,null,null ,'批发退货单'
  from PSUPOWERNOTIFICATION b(nolock)
  where ntime>= @piStartDate and ntime < @piEndDate 
  and topic = 'store.return.received'
  and businesskey is not null
  and not exists(select 1 from PS3_OnLineOrdGenBills  c(nolock) where c.genbillname = '批发退货单' and b.businesskey = c.ordno)
  and not exists(select 1 from PSOnlineOrdGenErrorLog ErrLog(nolock) where b.businesskey = ErrLog.ordno)
  
  -- 登记单据的来源。
  update b set b.billfrom = c.billfrom 
  from PSOnlineOrdGenErrorLog b,PS3_OnLineOrd c
  where b.ordno = c.ordno
    and b.genbillname = '批发单'
  
  update b set b.billfrom = c.billfrom 
  from PSOnlineOrdGenErrorLog b,PS3_OnLineReturnOrd c
  where b.ordno= c.ordno
    and b.genbillname = '批发退货单'
    
  
  -- 1、有交接没有集货流程，没有按流程操作。
  update b  set b.note = '订单未按流程操作，请手工补录批发单' from PSOnlineOrdGenErrorLog b 
  where not exists ( select 1 from PSUPOWERNOTIFICATION c(nolock) 
    where b.ordno = c.businesskey and c.topic = 'store.order.operation')
      and b.genbillname = '批发单'
  
  -- 2、商品代码录入问题。
  update n set n.note = s.note from 
    (select b.ordno,'商品代码 '+max(c.GDCODE)+' 不存在'  note
     from PSOnlineOrdGenErrorLog b ,PS3_OnLineOrdgoods c
      where b.ordno = c.ordno
      and c.gdcode not in(select code from goods(nolock) where  code <> '-')
           group by b.ordno
   ) s,PSOnlineOrdGenErrorLog n 
    where n.ordno = s.ordno
    and n.genbillname = '批发单'
  
  -- 3、商品经营属性的问题。
  update n set n.note = s.note from 
    (select  b.ordno,'商品 '+max(c.GDCODE)+' 淘汰且非买断，无法销售。'  note
     from PSOnlineOrdGenErrorLog b ,PS3_OnLineOrdgoods c
      where b.ordno = c.ordno
      and c.gdcode in(select code from goods(nolock) where KeepType & 8 = 8 and KeepType & 64 <> 64)
           group by b.ordno
   ) s,PSOnlineOrdGenErrorLog n 
    where n.ordno = s.ordno
      and n.genbillname = '批发单'
  
  
  -- 4、批发退商品代码录入问题。
  update n set n.note = s.note from 
    (select b.ordno,'商品代码 '+max(c.GDCODE)+' 不存在'  note
     from PSOnlineOrdGenErrorLog b ,PS3_OnLineReturnOrdgoods c
      where b.ordno = c.ordno
      and c.gdcode not in(select code from goods(nolock) where  code <> '-')
           group by b.ordno
   ) s,PSOnlineOrdGenErrorLog n 
    where n.ordno = s.ordno
    and n.genbillname = '批发退货单'
  
  -- 5、批发退商品经营属性的问题。
  update n set n.note = s.note from 
    (select  b.ordno,'商品 '+max(c.GDCODE)+' 淘汰且非买断，无法批发退。'  note
     from PSOnlineOrdGenErrorLog b ,PS3_OnLineReturnOrdgoods c
      where b.ordno = c.ordno
      and c.gdcode in(select code from goods(nolock) where KeepType & 8 = 8 and KeepType & 64 <> 64)
           group by b.ordno
   ) s,PSOnlineOrdGenErrorLog n 
    where n.ordno = s.ordno
      and n.genbillname = '批发退货单'
  end 

GO
