SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CRMSTAMPSCORULE_ABORT]
(
	@Num varchar(14),
	@Cls varchar(30),
	@Oper varchar(20),
	@ToStat int,
	@Msg varchar(255) output
) as
begin	
  declare @Stat int
  declare @TempNum varchar(14)    
	select @Stat = STAT from CRMSTAMPSCORULE(nolock) where NUM = @Num
	if @Stat <> 100 
	begin
		set @Msg = '不是已审核的单据，不能进行作废操作。'
		return(1)
	end
	
	select @TempNum = Num from CRMSTAMPSCORULE(nolock) where stat = 100 and chkdate = (select max(chkdate) from CRMSTAMPSCORULE(nolock)
		where stat = 100)
	
	-- 删除当前值
	if @TempNum = @Num
	begin
		delete from PS3STAMPSCORULE
		delete from PS3NOTSTAMPSCOGOODS 
	end
	
	--更新单据状态
	update CRMSTAMPSCORULE
  set STAT = @ToStat, ABORTDATE = GETDATE(), ABORTER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num 

	exec CRMSTAMPSCORULE_ADD_LOG @Num, @ToStat, '作废', @Oper
  return(0)
end 

GO
