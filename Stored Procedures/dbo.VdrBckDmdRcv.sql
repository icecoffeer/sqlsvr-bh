SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VdrBckDmdRcv]
(
  @bill_id int,
  @src_id int,
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) --with encryption
AS
BEGIN
	declare
		@cur_settleno int,		@stat smallint,
		@rcv_gid int,			@net_stat smallint,
		@net_type smallint,		@num char(14),
		@net_num char(14),		@pre_num char(14),
		@net_billid int,		@net_srcnum char(14),
		@net_psrgid int,		@loc_psrgid int,
		--
		@AutoGenBckBill int, 		@AllowedQtyPrice int,
		@UserProperty int,		@Message varchar (255),
		@AutoRcvGenBckFindVdrMothed int,@Vendor int,
		@BillSrc int,			@vReNumFore char(4),
		@vStoreFore char(4),		@vStoreFore2 char(4),
		@vFlowTag int,			@vInsSrc int,
		@vInsChkStoreGid int, 		@ret int
	set @ret = 0
	set @vFlowTag = 0
	exec optreadint 569, 'AllowedQtyPrice', 1, @AllowedQtyPrice Output
	exec optreadint 569, 'AutoRcvGenBckFindVdrMothed', 0, @AutoRcvGenBckFindVdrMothed Output
	exec optreadint 518, 'AutoGenBckBill', 0, @AutoGenBckBill Output

	select @userproperty = userproperty from system
	select @cur_settleno = max(no) from monthsettle
	select  @rcv_gid = RCV, @net_stat = STAT, @net_srcnum = srcnum,
		@net_type = NTYPE, @net_num = NUM, @net_psrgid = psrgid
	  from NVdrBckDmd where ID = @bill_id and SRC = @src_id
	if @@rowcount = 0 or @net_num is null
	begin
		SET @MSG = '该单据不存在'
		return(1)
	end

	select @loc_psrgid = lgid from empxlate where ngid = @net_psrgid
	/*if @net_psrgid is null or @loc_psrgid is null  --先不处理
	begin
		set @Msg = '找不到采购员信息'
		return(1)
	end*/

	if exists(select 1 from VdrBckDmd where num = @net_num and stat = @net_stat)
	begin
		SET @MSG = '该单据已经被接收'
		return(1)
	end
	if (select max(USERGID) from SYSTEM ) <>  @rcv_gid
	begin
		SET @MSG = '该单据的接收单位不是本单位'
		return(1)
	end
	if @net_type <> 1
	begin
		SET @MSG = '该单据不在接收缓冲区中'
		return(1)
	end
	--从单据前四位判断单据的来源
	set @vReNumFore = reverse(left(ltrim(@net_num), 4))
	select @BillSrc = gid from store(nolock)
	  where substring(reverse(rtrim(code)),1,1) = substring(@vReNumFore,1,1)
	  and ((substring(reverse(rtrim(code)),2,1) = substring(@vReNumFore,2,1)) or (substring(reverse(rtrim(code)),2,1) = ''))
	  and ((substring(reverse(rtrim(code)),3,1) = substring(@vReNumFore,3,1)) or (substring(reverse(rtrim(code)),3,1) = ''))
	  and ((substring(reverse(rtrim(code)),4,1) = substring(@vReNumFore,4,1)) or (substring(reverse(rtrim(code)),4,1) = ''))
	if @@rowcount <> 1
	begin
		set @msg = '根据单号前四位取来源单位时错误。['+@vReNumFore+']'
		return(1)
	end

	/*
	@vFlowTag:
	0 - Do nothing
	1 - Delete Local
	2 - Insert
	4 - Insert With No AllowedQtyPrice Control
	*/
	set @vFlowTag = 0
	--单据不存在
	if (select count(*) from vdrbckdmd a,nvdrbckdmd b where a.num = b.num
		and b.id = @bill_id and b.src = @src_id) = 0
	begin
		if @net_Stat = 401
		begin
			set @vInsSrc = @src_id
			set @vInsChkStoreGid = @rcv_gid
			if (@vFlowTag & 2) <> 2 set @vFlowTag = @vFlowTag + 2
		end
		else if @net_Stat <> 300
		begin
			set @vInsSrc = @BillSrc
			set @vInsChkStoreGid = @src_id
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
		end
		--else no process
	end
	else --单据存在
	begin
	        select @stat = a.stat, @num = a.num from vdrbckdmd a,nvdrbckdmd b
	        	where a.num = b.num and b.id = @bill_id and b.src = @src_id
                if @stat = 401 and @net_stat = 1600
                begin
                	set @msg = '不能传送预审状态的供应商退货申请单:' + @Num
			return(1)
                end
                if @stat = 401 and @net_Stat in (401, 411, 500, 410)  --300不接收
		begin
			if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			if @net_Stat = 401
			begin
				set @vInsSrc = @src_id
				set @vInsChkStoreGid = @rcv_gid
				if (@vFlowTag & 2) <> 2 set @vFlowTag = @vFlowTag + 2
			end
			else begin
				set @vInsSrc = @BillSrc
				set @vInsChkStoreGid = @src_id
				if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
			end
		end
                if @stat in (500) and @net_stat in (410) --审批后作废
			and (not exists(select 1 from VdrBckDmd where num = @num and rtrim(locknum) <> ''))
		begin
			set @vInsSrc = @BillSrc
			set @vInsChkStoreGid = @src_id
			if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
                end
                --本地单据是其它状态一概不接收
	end

	if (@vFlowTag & 1) = 1
	begin
		delete from vdrbckdmd where num = @num
		delete from vdrbckdmddtl where num = @num
	end
	if (@vFlowTag & 2) = 2 or (@vFlowTag & 4) = 4 --插入表头
	begin
		insert into VdrBckDmd (SRC, CHKSTOREGID, VENDOR, NUM, SETTLENO, RECCNT,
          		NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE, PSR, PSRGID, BEGINDATE,
			CANCELER, EXPDATE, STAT, LSTUPDTIME, SNDDATE, DMDSTORE, SRCNUM, BCKCLS)
          	  select  @vInsSrc, @vInsChkStoreGid, xlate.LGID, NUM, @cur_settleno, RECCNT,
                 	NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE, PSR, @loc_psrgid, BEGINDATE,
			CANCELER, EXPDATE, STAT,getdate(), getdate(), DMDSTORE, SRCNUM, BCKCLS
          	  from NVdrBckDmd, vdrxlate xlate
		  where SRC = @src_id and ID = @bill_id and xlate.NGID = NVdrBckDmd.Vendor
		if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END
	end
	if (@vFlowTag & 2) = 2
	begin
		if @AllowedQtyPrice = 0  --1743
			insert into VdrBckDmdDTL (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY)
	          	select NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY     --FDY 2003.11.26 1422
	          	from NVdrBckDmdDTL
			where SRC = @src_id AND ID = @bill_id
		else
			insert into VdrBckDmdDTL (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY)
	          	select NUM, LINE, GDGID, DMDCASES, DMDQTY, DMDCASES, DMDQTY, DMDPRICE, DMDPRICE, NOTE, CHECKED, INV, BCKEDQTY     --FDY 2003.11.26 1422
	          	from NVdrBckDmdDTL
			where SRC = @src_id AND ID = @bill_id
		if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END
	end
	if (@vFlowTag & 4) = 4
	begin
   		insert into VdrBckDmdDTL (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY)
          	select NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, DMDPRICE, PRICE, NOTE, CHECKED, INV, BCKEDQTY     --FDY 2003.11.26 1422
          	from NVdrBckDmdDTL
		where SRC = @src_id AND ID = @bill_id
		if @@error <> 0
		begin
			set @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		end
	end
	--Receive Bill Over
	EXEC VDRBCKDMDADDLOG @net_num, @net_stat, '接收', @OPER

	--Receive NBckDmdSplitDtl
	exec @ret = RcvBckdmdSplit @src_id, @bill_id, @oper, @msg output
	if @ret <> 0
	  return(@ret)
	--over

	select @num = Num from NVdrBckDmd where SRC = @src_id and ID = @bill_id
	--Check Out SrcNum
	if exists(select 1 from vdrbckdmd where num like @num)
	begin
		update bckdmd set
		    stat = 1400,
		    LstUpdTime = GetDate()
		where num in(
			select srcnum from BckDmdSplitDtl
			where newnum = @num and newcls = 'BCKDMD' and srccls = 'BCKDMD')
	end
	--AutoGen BckBill
	if @AutoRcvGenBckFindVdrMothed = 0
	begin
		select @Vendor = b.LGID  from nvdrbckdmd a, vdrxlate b
			where a.VENDOR = b.NGID and SRC = @src_id and ID = @bill_id
		update VDRBCKDMD SET VENDOR = @Vendor where NUM = @NUM
	end
	if @UserProperty <> 16 and @AutoGenBckBill = 1
	begin
		exec @ret = AutoGenDirAlc @Num, @Message Output
		set @MSG = @Message
	end
	delete from NVdrBckDmd where ID = @bill_id and SRC = @src_id
	delete from NVdrBckDmdDTL where ID = @bill_id and SRC = @src_id
	return(@ret)
END
GO
