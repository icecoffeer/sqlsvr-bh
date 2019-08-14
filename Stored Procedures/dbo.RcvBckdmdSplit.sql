SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvBckdmdSplit] 
(
  @src_id	int,
  @bill_id	int,
  @oper char(30),
  @msg varchar(255) output
)
as
begin
  declare @newnum varchar(14)
  
  select top 1 @newnum = newnum 
    from NBckDmdSplitDtl 
    where src = @src_id and id = @bill_id
    
	update NBckDmdSplitDtl 
	  set NBckDmdSplitDtl.stat = netb.stat
	  from BckDmdSplitDtl netb 
	  where NBckDmdSplitDtl.SrcNum = netb.SrcNum 
	  	and NBckDmdSplitDtl.GDGID = netb.GDGID 
	  	and NBckDmdSplitDtl.SrcCls = netb.SrcCls
	  	and NBckDmdSplitDtl.SRC = @src_id and NBckDmdSplitDtl.ID = @bill_id
	  	
	delete BckDmdSplitDtl 
	  from NBckDmdSplitDtl netb 
	  where BckDmdSplitDtl.SrcNum = netb.SrcNum 
	  	and BckDmdSplitDtl.GDGID = netb.GDGID
	  	and BckDmdSplitDtl.SrcCls = netb.SrcCls
	  	and netb.SRC = @src_id and netb.ID = @bill_id
	  	
	insert into BckDmdSplitDtl(DMDSTORE, NEWNUM, SRCNUM, NEWCLS, SRCCLS, GDGID, NEWLINE, SRCLINE, STAT, OCRDATE, RCVTIME)
	  select DMDSTORE, NEWNUM, SRCNUM, NEWCLS, SRCCLS, GDGID, NEWLINE, SRCLINE, STAT, OCRDATE, GETDATE()
	  from NBckDmdSplitDtl where SRC = @src_id AND ID = @bill_id
	  
	delete NBckDmdSplitDtl 
	  from BckDmdSplitDtl b
	  where NBckDmdSplitDtl.SRC = @src_id and NBckDmdSplitDtl.ID = @bill_id
	  
	if @@error <> 0 
	begin
		set @msg = '接收拆分生成的单据'+@newnum+'拆分关系单据失败'
		return(1)
	end
	
    --更新拆分单据状态
	update bckdmd set 
	    stat = 1400, 
	    LstUpdTime = GetDate()
	where num in(
		select Split.srcnum from BckDmdSplitDtl Split, 
		  BckDmd newbd(nolock), BckDmd srcbd(nolock)
		where Split.srccls = 'BCKDMD' and Split.newcls = 'BCKDMD' 
		  and newbd.Num = Split.newnum 
		  and srcbd.Num = Split.srcnum and srcbd.stat <> 1400 )

	update bckdmd set 
	    stat = 1400, 
	    LstUpdTime = GetDate()
	where num in(
		select Split.srcnum from BckDmdSplitDtl Split, 
		  VdrBckDmd newbd(nolock), BckDmd srcbd(nolock)
		where Split.srccls = 'BCKDMD' and Split.newcls = 'VDRBCKDMD'
		  and newbd.Num = Split.newnum 
		  and srcbd.Num = Split.srcnum and srcbd.stat <> 1400 )
	return(0)
end
GO
