SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DecPreAlcQty] (
  @piStore int,
  @piWrh int,
  @piGdgid int,
  @piQty money,
  @piSubwrh int = null,
  @piMode smallint = 0,   --@pimode为0，1时，保证inv表的rsvalcqty不小于0；为-1时，表示该字段可以为负值；默认值为0。
  @poOpqty money output
) with encryption as
begin
  declare @num int, @avlqty money
  
  select @num = min(num) from inv
  where wrh = @piWrh and gdgid = @piGdgid and store = @piStore
  
  if @num is null 
  begin
    insert into INV (STORE, WRH, GDGID) values (@piStore, @piWrh, @piGdgid)
    select @num = min(num) from inv
    where wrh = @piWrh and gdgid = @piGdgid and store = @piStore
    --raiserror('没有库存记录', 16, 1)
    --return 1  
  end
  
  /*if (select isnull(rsvalcqty, 0) - @piQty from inv(nolock) where num = @num) < 0 
  begin
    raiserror('预配数不允许修改为负值', 16, 1)
    return 2  	
  end*/
  
  select @avlqty = isnull(rsvalcqty, 0) - @piQty from inv(nolock) where num = @num
  if @avlqty < 0 
  begin
    if @piMode = 0 
      set @piQty = 0 
    else if @pimode = 1
      select @piQty = rsvalcqty from inv(nolock) where num = @num
  end

  update inv set rsvalcqty = rsvalcqty - @piQty where num = @num
  set @poOpqty = @piQty
    
  if @piSubwrh is not null
  begin
    if not exists (select 1 from subwrhinv where gdgid = @piGdgid and subwrh = @piSubwrh and wrh = @piWrh)
    begin
      raiserror('没有相应的货位库存记录', 16, 1)
      return 3
    end else
    begin
      update subwrhinv set rsvalcqty = rsvalcqty - @piQty where gdgid = @piGdgid and subwrh = @piSubwrh and wrh = @piWrh
    end
  end
  
  return 0
end
GO
