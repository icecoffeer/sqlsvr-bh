SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SETDXNAMEMENU](@moduleno int, @dxname varchar(50))
--本存储过程改变菜单项中的代销名称，moduleno表示menu表中的moduleno列，dxname表示新的代销名称
as
begin
  declare 
  @name varchar(50)
  select @name = name from menu where moduleno=@moduleno
  if @dxname = '月销'
  begin  
    update menu set leftchild = replace(@name, '代销', '月销') where leftChild=@name
    update menu set rightchild = replace(@name, '代销', '月销') where rightChild=@name
    update menu set name = replace(@name, '代销', '月销') where moduleno= @moduleno
  end
  if @dxname = '代销'
  begin
    update menu set leftchild = replace(@name, '月销', '代销') where leftChild=@name
    update menu set rightchild = replace(@name, '月销', '代销') where rightChild=@name
    update menu set name = replace(@name, '月销', '代销') where moduleno= @moduleno
  end
end
GO
