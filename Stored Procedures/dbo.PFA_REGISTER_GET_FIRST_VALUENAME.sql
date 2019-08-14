SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_GET_FIRST_VALUENAME] (
  @poResult varchar(500) output       --返回子键名；若没有子键，则返回null
) as
begin
  declare @sCurrKey varchar(500), @nItemNo smallint, @sValueName varchar(500)
  
  exec PFA_REGISTER_GET_CURRENTKEY @sCurrKey output
  select @nItemNo = min(ITEMNO) from FAREGISTER
    where FKEY = @sCurrKey and FTYPE = 0
  select @sValueName = CAPTION from FAREGISTER
    where FKEY = @sCurrKey and FTYPE = 0 and ITEMNO = @nItemNo
  if @@rowcount = 0
    set @poResult = null
  else
    set @poResult = @sValueName
  return 0
end
GO
