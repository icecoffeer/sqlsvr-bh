SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[dxm_isallhz](@str varchar(50))  
----判断输入字符是否都是汉字  
returns smallint  
as  
begin  
declare @flag smallint  
declare @i  int  
declare @con  varchar(500)  
declare @tmp  varchar(10)  
select  @flag=1  
select  @con=rtrim(replace(@str, '  ', ' '))  
select  @i=1  
while  @i <=len(@con)  
begin  
  select  @tmp=SUBSTRING(@con,@i,1)   
  if  UNICODE(@tmp) <=255   
  begin   
      select @flag=0  
      break  
  end  
  select  @i=@i+1  
end  
return @flag  
end  
GO
