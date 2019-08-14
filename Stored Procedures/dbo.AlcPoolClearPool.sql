SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolClearPool](
	@storegid	int
)
as
begin
	declare	@gdgid	int
	declare @psrdatediff int
	declare @orddatediff int
	declare	@GenAlcLimit int		--是否对没有分货员和配货员的配货池数据生成单据,任务单1536

	exec OptReadInt 500, 'GenAlcLimit', 0, @GenAlcLimit output
	exec OptReadInt 500, 'psrdatediff', 0, @psrdatediff output
	exec OptReadInt 500, 'orddatediff', 0, @orddatediff output
		
	exec AlcPoolWriteLog 0, 'SP:AlcPoolClearPool', '清除配货池信息'
	if object_id('c_pool') is not null deallocate c_pool
	declare c_pool cursor for
	select gdgid
	from alcpooltemp
	where storegid = @storegid
	open c_pool
	fetch next from c_pool into @gdgid
	while @@fetch_status = 0
	begin
		if @GenAlcLimit = 0 
			delete from alcpool
			where storegid = @storegid
				and gdgid = @gdgid 
				and (((srcgrp = 1) and (dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
					or (srcgrp = 2 and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
					or (srcgrp = 3))
		else
			delete from alcpool
			where storegid = @storegid
				and gdgid = @gdgid and alcpool.Aparter is not null and alcpool.Alcer is not null 
				and (((srcgrp = 1) and (dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)))
					or (srcgrp = 2 and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102))
					or (srcgrp = 3))
			
		fetch next from c_pool into @gdgid
	end
	close c_pool
	deallocate c_pool
	
	exec AlcPoolRebuildLine @storegid
	
	return (0)
end
GO
