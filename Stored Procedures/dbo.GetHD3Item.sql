SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetHD3Item](
@ItemName varchar(50)
)
as
begin
  select @ItemName as 查询字段, 'collateitem表' as 表, '' as 子表, 
  '(' + rtrim(a.TABLENAME) + ':' + rtrim(a.TABLELABEL) + ')' + cast(b.ITEMNO as varchar(20)) as 信息1,
  cast(FIELDNAME as varchar(100)) as 信息2, 
  cast(FIELDLABEL as varchar(100)) as 信息3, 
  case b.TYPE when 1 then '字符类型' when 3 then '整数类型'
  when 6 then '小数类型' when 11 then '时间类型' else '未知类型' end as 信息4     
  from [COLLATE] a,[COLLATEITEM] b where a.[NO] = b.COLLATENO
  and b.FIELDLABEL = @ItemName
  union all
  select @ItemName as 查询字段, 
  'collate表' as 表, 
  cast('' as varchar(100)) as 子表,
  cast(TABLENAME as varchar(100)) as 信息1, 
  TABLELABEL as 信息2,
  '' as 信息3, 
  '' as 信息4 
  from [COLLATE] where TABLENAME = @ItemName  
  union all
  select @ItemName as 查询字段, 
  'collate表' as 表, 
  'collateitem表' as 子表, 
  cast(b.ITEMNO as varchar(100)) as 信息1,
  b.FIELDNAME as 信息2 , 
  b.FIELDLABEL as 信息3, 
  case b.TYPE when 1 then '字符类型' when 3 then '整数类型'
  when 6 then '小数类型' when 11 then '时间类型' else '未知类型' end 信息4     
  from [COLLATE] a,[COLLATEITEM] b where a.NO = b.COLLATENO
  and a.TABLENAME = @ItemName
  union all
  select 
  @ItemName as 查询字段 , 
  'module表' as 表 , 
  '' as 子表, 
  cast(NO as varchar(100)) as 信息1,
  NAME as 信息2, 
  MEMO as 信息3, 
  UNITNAME as 信息4 
  from module a where Name like '%' + @ItemName + '%' or UNITNAME
  like '%' + @ItemName + '%'
  union all
  select @ItemName as 查询字段 , 'hdoption表' as 表 , '' as 子表, 
  '(val)' + OPTIONVALUE as 信息1,
  NOTE as 信息2, '(def)' + OPTIONDEFAULT as 信息3, '(Mudule)' + CAST(MODULENO as varchar(100)) as 信息4 
  from hdoption where optioncaption like '%' + @ItemName + '%'
end
GO
