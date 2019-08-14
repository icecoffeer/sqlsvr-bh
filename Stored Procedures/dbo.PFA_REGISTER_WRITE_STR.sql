SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_WRITE_STR] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @piValue varchar(500)             --返回取值
) as
begin
  declare @sCurrKey varchar(500), @nItemNo smallint,
    @sPath varchar(500), @sValueName varchar(64), @nWithPath integer
    
  set @sPath = rtrim(@piValueName)
  set @sValueName = @sPath
  set @nWithPath = 0
  if charindex('\', @sPath) > 0
  begin
    exec PFA_REGISTER_TO_ABSKEY @sPath, @sPath output
    exec PFA_REGISTER_EXTRACT_LASTKEY @sPath, @sPath output, @sValueName output
    exec PFA_REGISTER_PUSH_KEY @sPath, 1
    set @nWithPath = 1
  end
  
  exec PFA_REGISTER_GET_CURRENTKEY @sCurrKey output
  if exists (select 1 from FAREGISTER
    where FKEY = @sCurrKey and CAPTION = @sValueName and FTYPE = 0)
    update FAREGISTER set FVALUE = @piValue
      where FKEY = @sCurrKey and CAPTION = @sValueName and FTYPE = 0
  else
  begin
    select @nItemNo = isnull(max(ITEMNO), 0) + 1 from FAREGISTER
      where FKEY = @sCurrKey and FTYPE = 0
    insert into FAREGISTER (FKEY, ITEMNO, CAPTION, FVALUE, FTYPE)
      values (@sCurrKey, @nItemNo, @sValueName, @piValue, 0)
  end
  
  if @nWithPath = 1
    exec PFA_REGISTER_POP_KEY
  return 0
end
GO
