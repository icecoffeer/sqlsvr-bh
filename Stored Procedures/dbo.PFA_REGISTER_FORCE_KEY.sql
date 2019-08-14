SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_FORCE_KEY] (
  @piKey varchar(500)                   --指定的路径
) as
begin
  declare @sPath varchar(500), @sKey varchar(500), @nItemNo smallint,
    @nItemNo2 smallint
  declare @Stack table (
    ITEMNO int not null, FKEY varchar(500), primary key (ITEMNO))
  
  if @piKey is null or rtrim(@piKey) = '' or rtrim(@piKey) = '\' return 0

  set @sPath = rtrim(@piKey)
  set @nItemNo2 = -1
  while @sPath <> '\'
  begin
    exec PFA_REGISTER_EXTRACT_LASTKEY @sPath, @sPath output, @sKey output
    if exists (select 1 from FAREGISTER
      where FKEY = @sPath and CAPTION = @sKey and FTYPE = 1)
    begin
      set @sPath = @sPath + @sKey + '\'
      break
    end
    set @nItemNo2 = @nItemNo2 + 1
    insert into @Stack (ITEMNO, FKEY) values (@nItemNo2, @sKey)
  end
  
  while @nItemNo2 >= 0
  begin
    select @sKey = FKEY from @Stack where ITEMNO = @nItemNo2
    select @nItemNo = isnull(max(ITEMNO), 0) + 1 from FAREGISTER
      where FKEY = @sPath and FTYPE = 1
    insert into FAREGISTER (FKEY, ITEMNO, CAPTION, FVALUE, FTYPE)
      values (@sPath, @nItemNo, @sKey, @sKey, 1)
    set @nItemNo2 = @nItemNo2 - 1
    set @sPath = @sPath + @sKey + '\'
  end
  
  return 0
end
GO
