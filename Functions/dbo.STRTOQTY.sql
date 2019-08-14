SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[STRTOQTY](
  @qtystr varchar(50),
  @qpc decimal(24, 4)
) returns decimal(24, 4) as
begin
  declare
    @tempqtystr varchar(50), --临时数量字符串
    @leftqtystr varchar(50), --传入的收货件数的整件数部分
    @rightqtystr varchar(50), --传入的收货件数的零散数部分
    @leftqty decimal(24, 4),  --整件数
    @rightqty decimal(24, 4)  --单品数

	--传入数量字符串形如：-4.-12

  --初始化变量
  set @tempqtystr = @qtystr
  set @leftqtystr = ''
  set @rightqtystr = ''
  set @leftqty = 0
  set @rightqty = 0

  --将分隔符替换成“.”  --?
  set @tempqtystr = replace(@tempqtystr, '+', '.')
  --去空格
  set @tempqtystr = replace(@tempqtystr, ' ', '')
  
  --解析数量
  if @tempqtystr = ''
  begin
    set @leftqtystr = ''
    set @rightqtystr = ''
  end
  else if charindex ('.', @tempqtystr ) = 0
  begin
    set @leftqtystr = @tempqtystr
    set @rightqtystr = ''
  end
  else begin
    set @leftqtystr = substring(@tempqtystr, 1, charindex ('.', @tempqtystr ) - 1)
    set @rightqtystr = substring(@tempqtystr, charindex ('.', @tempqtystr ) + 1, 
    len(@tempqtystr) - charindex ('.', @tempqtystr ))
  end
  
  if @leftqtystr = ''
    set @leftqtystr = '0'
  if @rightqtystr = ''
    set @rightqtystr = '0'
  select @leftqty = @qpc * convert(decimal(24, 4), @leftqtystr)
  select @rightqty = convert(decimal(24, 4), @rightqtystr)

  return @leftqty + @rightqty
end
GO
