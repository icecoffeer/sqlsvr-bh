SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--查看表中列名的存储过程
create proc [dbo].[proc_item] @tablename char(32)  
as  
select master,tablename,tablelabel,  
     --master '主表编号',tablename '表名',tablelabel '显示表名',  
       --type=case  
case [collate].style   
when'B' then '单据'   
when'E' then 'EC'   
when'X' then '卡'   
when'XX' then '卡相关'   
when'C' then '当前值'   
when'O' then '基本资料'   
when'S' then '系统表'   
when'Y' then '年报'   
when'M' then '月报'   
when'D' then '日报'   
when'BN' then '网络单据'   
when'ON' then '网络基本资料'   
when'CV' then '当前值视图'   
when'OV' then '基本资料视图'   
when'SV' then '系统表视图'   
when'YV' then '年报视图'   
when'MV' then '月报视图'   
when'DV' then '日报视图'   
else '其他'  

end        
from [collate] where tablename=@tablename  
  
select collateno,itemno,fieldname,  
     --collateno '数据表编号',itemno '字段编号',fieldname '字段名',  
       fieldlabel,type  
     --fieldlabel '显示字段名',type '类型'  
from collateitem  
where collateno in (select no from [collate] where tablename=@tablename)  
GO
