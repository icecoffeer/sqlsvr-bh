SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_GET_PRIOR_KEYNAME] (
  @piCurrKey varchar(500),            --当前子键名
  @poResult varchar(500) output       --返回子键名；若没有子键，则返回null
) as
begin
  declare @sCurrKey varchar(500), @nItemNo smallint, @sKeyName varchar(500)
  
  exec PFA_REGISTER_GET_CURRENTKEY @sCurrKey output
  select @nItemNo = ITEMNO from FAREGISTER
    where FKEY = @sCurrKey and FTYPE = 1 and CAPTION = @piCurrKey
  select @nItemNo = max(ITEMNO) from FAREGISTER
    where FKEY = @sCurrKey and FTYPE = 1 and ITEMNO < @nItemNo
  select @sKeyName = CAPTION from FAREGISTER
    where FKEY = @sCurrKey and FTYPE = 1 and ITEMNO = @nItemNo
  if @@rowcount = 0 
    set @poResult = null
  else
    set @poResult = @sKeyName
  return 0
end
GO
