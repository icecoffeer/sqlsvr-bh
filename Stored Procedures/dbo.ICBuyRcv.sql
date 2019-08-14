SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ICBuyRcv]
as
begin
  declare @Msg varchar(200)
	,@Result int
  declare @ID int, @Src int

  declare cur_chr cursor for
    select ID, Src
    from NICbuy1 where ntype = 1 and nstat = 0

  open cur_chr
  fetch next from cur_chr into @ID,@Src
  while @@fetch_status = 0
  begin
	select @Result = 0
	begin transaction

	exec @Result = NICBuyRcv @ID,@SRC,@Msg output
	if @Result <> 0
	begin
		Rollback Transaction
		update nicbuy1 set nstat = 1,nnote = @msg where src = @src and id = @ID
	end
	else
		commit transaction
    fetch next from cur_chr into @ID,@SRC
  end
  close cur_chr
  deallocate cur_chr
end
GO
