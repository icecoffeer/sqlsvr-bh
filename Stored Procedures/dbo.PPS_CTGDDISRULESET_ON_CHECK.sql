SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_CTGDDISRULESET_ON_CHECK] (
  @piNum varchar(32),   
  @piOper varchar(30),
  @piToStat integer,
  @poErrMsg varchar(255) output       --出错信息
)as
begin
	declare
	  @vUUID varchar(32),
	  @vCardType varchar(20),
	  @vGDGid integer, 
	  @vGDQpc integer,
	  @vDisCount decimal(24,4),
	  @vExDis integer,
	  @vNote varchar(255)
	  
	--更新状态
	update PSCTGDDISRULESET set stat = 100, CHECKER = @piOper, ChkDate = GetDate(), Modifier = @piOper, LstUpdTime = GetDate() 
	where Num = @piNum
	declare curDtl cursor for
	  select UUID, CardType, GDGid, GDQpc, DisCount, ExDis, Note 
	  from PSCTGDDisRuleSetDtl where Num = @piNum
	open curDtl 
	fetch next from curDtl into @vUUID, @vCardType, @vGDGid, @vGDQpc, @vDisCount, @vExDis, @vNote
	while @@fetch_status = 0  
	begin
	  insert into PSCTGDDISRULE(UUID, CardType, GDGid, GDQpc, DisCount, ExDis, Note, BeginDate, EndDate)
	  values(@vUUID, @vCardType, @vGDGid, @vGDQpc, @vDisCount, @vExDis, @vNote, convert(varchar(10), GetDate(), 102), '2099.12.31')
	  exec PPS_CTGDDISRULE_ON_ADDNEW @vUUID, @piOper, @poErrMsg	  
	  fetch next from curDtl into @vUUID, @vCardType, @vGDGid, @vGDQpc, @vDisCount, @vExDis, @vNote
  end	
  close curDtl
   deallocate curDtl
  exec PPS_CTGDDISRULESET_ADD_LOG @piNum, 0, 100, @piOper, @poErrMsg
  return(0)
end 
GO
