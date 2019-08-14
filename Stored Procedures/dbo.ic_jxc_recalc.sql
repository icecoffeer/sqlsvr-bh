SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[ic_jxc_recalc]            
 @begindate datetime,            
 @enddate datetime            
as            
begin            
 if  exists(select 1 from ic_jxc where insdate >= @begindate)        
 begin        
   delete from ic_jxc where insdate >= @begindate and insdate <=@enddate            
  end        
           
  insert into ic_jxc (insdate,zhika,faka,chongzhi,xiaofei,tuihuo,chika,zuofei)            
     select convert(char(10),fildate,120),            
        sum(case when iccardhst.action ='发卡' and iccardhst.store = 5000000 and iccardhst.cardtype like 'IC%' then 5 else 0 end),            
        sum(case when iccardhst.action ='发卡' and iccardhst.store = 5000000 and iccardhst.cardtype like 'IC%' then iccardhst.occur else 0 end),            
        sum(case when iccardhst.action ='充值' and iccardhst.store = 5000000 and iccardhst.cardtype like 'IC%' then iccardhst.occur else 0 end),            
        sum(case when iccardhst.action ='消费'    then iccardhst.occur else 0 end),            
        sum(case when iccardhst.action ='退货充值'    then iccardhst.occur else 0 end),          
        sum(case when iccardhst.action ='吃卡修正'   then iccardhst.occur else 0 end),       
        sum(case when iccardhst.action ='作废' and cardnum like '818%' and note not like '%重复作废%' then 5.00 else 0 end)         
  from iccardhst(nolock)         
  where fildate >= @begindate and fildate <= @enddate           
  group by convert(char(10),fildate,120)            
  order by convert(char(10),fildate,120)            
end      
      

GO
