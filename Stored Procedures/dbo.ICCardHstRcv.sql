SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[ICCardHstRcv]
as
begin
  declare @Msg varchar(200)
	,@Result int
  declare @ID int, @Src int

  declare cur_chr cursor for
    select ID, Src
    from NICCardHst where ntype = 1 and nstat = 0  order by fildate

  open cur_chr
  fetch next from cur_chr into @ID,@Src
  while @@fetch_status = 0
  begin
	begin transaction
	select @Result = 0

	exec @Result = OneICCardHstRcv @SRC,@ID,@Msg output
	if @Result <> 0
	begin
		Rollback Transaction
		update niccardhst set nstat = 1,nnote = @Msg where Src = @Src and ID = @ID
	end
	else
		commit transaction
    fetch next from cur_chr into @ID,@SRC
  end

  close cur_chr
  deallocate cur_chr

end



GO
