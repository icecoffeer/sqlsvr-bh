SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_EXTRACT_LASTKEY] (
  @piInput varchar(500),                --传入的绝对路径
  @poPath varchar(500) output,          --传出，路径部分
  @poKey varchar(500) output            --传出，最后一个键
) as
begin
  declare @i int, @sChar char(1)
  
  set @poPath = rtrim(@piInput)
  set @poKey = ''
  if @poPath is null or @poPath = '' or @poPath = '\' return 0
  
  set @poPath = reverse(@poPath)
  set @i = charindex('\', @poPath, 2);
  set @poKey = reverse(substring(@poPath, 2, @i - 2));
  set @poPath = reverse(substring(@poPath, @i, len(@poPath) - @i + 1));
  return 0
end
GO
