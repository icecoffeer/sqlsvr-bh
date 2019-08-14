SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RATEDLT]
	@old_num   char(10),
	@new_oper  int
as	
begin
	declare @conflict smallint,
		@max_num  char(10),
		@new_num  char(10),
		@stat smallint
	
	select @conflict = 1, @max_num = @old_num
        while @conflict = 1
	begin
	    execute NEXTBN @max_num, @new_num output
	    if exists (select * from SVI where NUM = @new_num and CLS = '联销')
	      select @max_num = @new_num, @conflict = 1
	    else
	      select @conflict = 0
        end
		
	select @stat = stat from SVI where num = @old_num and cls = '联销'
	if @stat <> 1 
	begin
		raiserror('冲单的不是已审核的单据',16,1)
		return(1)
	end
	execute RATEDLTNUM @old_num, @new_oper, @new_num   --执行冲单操作	
	return(0)
end
GO
