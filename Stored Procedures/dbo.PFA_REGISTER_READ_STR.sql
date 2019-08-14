SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_READ_STR] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @poResult varchar(500) output,    --返回取值
  @piDefault varchar(500) = ''      --默认值
) as
begin
  declare @sCurrKey varchar(500), @nRet integer,
    @sPath varchar(500), @sValueName varchar(64), @nWithPath integer
    
  set @sPath = rtrim(@piValueName)
  set @sValueName = @sPath
  set @nWithPath = 0
  if charindex('\', @sPath) > 0
  begin
    exec PFA_REGISTER_TO_ABSKEY @sPath, @sPath output
    exec PFA_REGISTER_EXTRACT_LASTKEY @sPath, @sPath output, @sValueName output
    exec @nRet = PFA_REGISTER_KEY_EXISTS @sPath
    if @nRet = 0
    begin
      set @poResult = @piDefault
      return 0
    end
    exec PFA_REGISTER_PUSH_KEY @sPath
    set @nWithPath = 1
  end
    
  exec PFA_REGISTER_GET_CURRENTKEY @sCurrKey output
  select @poResult = FVALUE from FAREGISTER
    where FKEY = @sCurrKey and CAPTION = @sValueName
  if @@rowcount = 0
    set @poResult = @piDefault
  
  if @nWithPath = 1
    exec PFA_REGISTER_POP_KEY
  return 0
end
GO
