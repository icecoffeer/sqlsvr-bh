SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3NOTSCOREGDSCOPE_ABORT]
(
	@Num varchar(14),
	@Cls varchar(10),
	@Oper varchar(20),
	@ToStat int,
	@Msg varchar(255) output
) as
begin	
  declare @Stat int    
	select @Stat = STAT from PS3NOTSCOREGDSCOPE(nolock) where NUM = @Num
	if @Stat <> 100 
	begin
		set @Msg = '不是已审核的单据，不能进行作废操作。'
		return(1)
	end

	-- 删除当前值
	delete from PS3NOTSCOREGDSCOPEINV where SRCNUM = @Num and SRCCLS = @cls
	
	--更新单据状态
	update PS3NOTSCOREGDSCOPE
  set STAT = @ToStat, ABORTDATE = GETDATE(), ABORTER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

	exec PS3NOTSCOREGDSCOPE_ADD_LOG @Num, @Cls, @ToStat, '作废', @Oper
  return(0)
end 
GO
