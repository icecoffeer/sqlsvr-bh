SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RECEIVEBCKDMD]
(
  @bill_id int,
  @src_id int,
  @oper char(30),
  @msg varchar(255) output
) --with encryption
AS
BEGIN
	declare
		--Sys info
		@UserProperty int,		@UserGid int,
		@Message varchar(255),		@ret smallint,
		--Bill Info
		@cur_settleno int,		@stat smallint,
		@rcv_gid int,			@net_stat smallint,
		@net_type smallint,		@num char(14),
		@net_num char(14),		@pre_num char(14),
		@net_billid int,		@net_dmdstore int,
		@net_psrgid int,		@loc_psrgid int,
		--new
		@vBillSrc int,			@vReNumFore char(4),
		@vStoreFore char(4),		@vStoreFore2 char(4),
		@vInsSrc int,			@vInsChkStoreGid int,
		--Options
		@UseInvChgRelQty int,		@AllowedQty int,
		@AutoGenBckBill int,
		--Control info
		@vFlowTag int

	set @ret = 0
	set @vFlowTag = 0
	exec optreadint 0,'UseInvChgRelQty',0,@UseInvChgRelQty output
	exec optreadint 518, 'AllowedQty', 0, @AllowedQty output
	exec optreadint 518, 'AutoGenBckBill', 0, @AutoGenBckBill output

	select @UserProperty = USERPROPERTY, @UserGid = USERGID from system
	select @cur_settleno = max(no) from monthsettle

	select  @net_num = NUM,   @rcv_gid = RCV,  @net_dmdstore = dmdstore,
		@net_stat = STAT, @net_type = NTYPE, @net_psrgid = psrgid
		from NBCKDMD
	  where ID = @bill_id and SRC = @src_id
	--Check
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

	if exists(select 1 from BckDmd where num = @net_num and stat = @net_stat)
	begin
		set @msg = '该单据已经被接收'
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
	select @vBillSrc = gid from store(nolock)
	  where substring(reverse(rtrim(code)),1,1) = substring(@vReNumFore,1,1)
	  and ((substring(reverse(rtrim(code)),2,1) = substring(@vReNumFore,2,1))
	    or ((isnull(substring(reverse(rtrim(code)),2,1), '') = '') and substring(@vReNumFore,2,1) = '0')
	    )
	  and ((substring(reverse(rtrim(code)),3,1) = substring(@vReNumFore,3,1))
	    or ((isnull(substring(reverse(rtrim(code)),3,1), '') = '') and substring(@vReNumFore,3,1) = '0')
	    )
	  and ((substring(reverse(rtrim(code)),4,1) = substring(@vReNumFore,4,1))
	    or ((isnull(substring(reverse(rtrim(code)),4,1), '') = '') and substring(@vReNumFore,4,1) = '0')
	    )
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
	--Control Flow
	--单据不存在
	if (select count(*) from bckdmd a,nbckdmd b where a.num = b.num
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
			set @vInsSrc = @vBillSrc
			set @vInsChkStoreGid = @src_id
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
		end
	end
	else --单据存在
	begin
	        select @stat = a.stat, @num = a.num
	          from bckdmd a,nbckdmd b
	          where a.num = b.num and b.id = @bill_id and b.src = @src_id

                if @stat = 401 and @net_stat = 1600
                begin
                	set @msg = '不能传送预审状态的供应商退货申请单:' + @Num
			return(1)
                end
                if @stat = 401 and @net_Stat in (401, 411, 400, 410, 3000) --300不接收  --ShenMin
		begin
			if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			if @net_Stat = 401
			begin
				set @vInsSrc = @src_id
				set @vInsChkStoreGid = @rcv_gid
				if (@vFlowTag & 2) <> 2 set @vFlowTag = @vFlowTag + 2
			end
			else begin
				set @vInsSrc = @vBillSrc
				set @vInsChkStoreGid = @src_id
				if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
			end
		end
                if @stat in (3000, 400) and @net_stat in (410) --审批后作废
			and (not exists(select 1 from bckdmd where num = @num and rtrim(locknum) <> ''))
		begin
			set @vInsSrc = @vBillSrc
			set @vInsChkStoreGid = @src_id
			if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
                end
               --ShenMin
                if @stat = 3000 and @net_stat = 3100
		begin
			if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			set @vInsSrc = @vBillSrc
			set @vInsChkStoreGid = @src_id
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
                end
                --本地单据是其它状态一概不接收
	end
	--Receive Process
	if (@vFlowTag & 1) = 1
	begin
		delete from bckdmd where num = @num
		delete from bckdmddtl where num = @num
	end
	if (@vFlowTag & 2) = 2 or (@vFlowTag & 4) = 4 --插入表头
	begin
		insert into bckdmd (SRC, CHKSTOREGID, NUM, SETTLENO, RECCNT, BEGINDATE,
          		NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE, PSR, PSRGID,
			CANCELER, EXPDATE, STAT, LSTUPDTIME, SNDDATE, BCKCLS, DMDSTORE, SRCNUM)
          	select  @vInsSrc, @vInsChkStoreGid, NUM, @cur_settleno, RECCNT, BEGINDATE,
                 	NOTE, FILDATE, FILLER, CHKDATE, CHECKER, CACLDATE, PSR, @loc_psrgid,
			CANCELER, EXPDATE, STAT,getdate(), null, BCKCLS, DMDSTORE, SRCNUM
          	from nbckdmd
		where SRC = @src_id AND ID = @bill_id

		if @@error <> 0
		BEGIN
			SET @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		END
	end
	if (@vFlowTag & 2) = 2  --插入明细
	begin
		if @AllowedQty = 0  --1743
		begin
			--为慈客隆定制 Fanduoyi
			--大->小
			if @UseInvChgRelQty = 1
			begin
		   		insert into bckdmddtl (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY,NOTE, CHECKED, INV, BCKEDQTY)
		          	select NUM, LINE, isnull(i.gdgid2,d.GDGID) gdgid,
		          		CASES, isnull(d.QTY * i.relqty, d.qty) qty,
		          		DMDCASES, isnull(d.DMDQTY * i.relqty, d.dmdqty) dmdqty,
		          		NOTE, CHECKED, INV, BCKEDQTY
		          	from nbckdmddtl d, invchg i
				where d.SRC = @src_id AND ID = @bill_id and d.gdgid *= i.gdgid

				update bckdmddtl set CASES = qty / qpc, dmdcases = dmdqty / qpc
				from goods g(nolock)
				where g.gid = bckdmddtl.gdgid and bckdmddtl.num = (select num from NBCKDMD where SRC = @src_id AND ID = @bill_id)
				and bckdmddtl.gdgid in (select gdgid2 from invchg(nolock))
			end
			else
				insert into bckdmddtl (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY)
		          	select NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY     --FDY 2003.11.26 1422
		          	from NBCKDMDDTL
				where SRC = @src_id AND ID = @bill_id
		end
		else
		begin
			--为慈客隆定制 Fanduoyi
			--大->小
			if @UseInvChgRelQty = 1
			begin
		   		insert into bckdmddtl (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY,NOTE, CHECKED, INV, BCKEDQTY)
		          	select NUM, LINE, isnull(i.gdgid2,d.GDGID) gdgid,
		          		DMDCASES, isnull(d.DMDQTY * i.relqty, d.dmdqty) qty,
		          		DMDCASES, isnull(d.DMDQTY * i.relqty, d.dmdqty) dmdqty,
		          		NOTE, CHECKED, INV, BCKEDQTY    --FDY 2003.11.26 1422
		          	from nbckdmddtl d, invchg i
				where d.SRC = @src_id AND ID = @bill_id and d.gdgid *= i.gdgid

				update bckdmddtl set cases = qty / qpc, dmdcases = dmdqty / qpc
				from goods g(nolock)
				where g.gid = bckdmddtl.gdgid and bckdmddtl.num = (select num from NBCKDMD where SRC = @src_id AND ID = @bill_id)
				and bckdmddtl.gdgid in (select gdgid2 from invchg(nolock))
			end
			else
				insert into bckdmddtl (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY)
		          	select NUM, LINE, GDGID, DMDCASES, DMDQTY, DMDCASES, DMDQTY, NOTE, CHECKED, INV, BCKEDQTY     --FDY 2003.11.26 1422
		          	from NBCKDMDDTL
				where SRC = @src_id AND ID = @bill_id
		end
		if @@error <> 0
		begin
			set @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		end
	end
	if (@vFlowTag & 4) = 4 --插入明细
	begin
		--为慈客隆定制 Fanduoyi
		--大->小
		if @UseInvChgRelQty = 1
		begin
	   		insert into bckdmddtl (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY,NOTE, CHECKED, INV, BCKEDQTY)
	          	select NUM, LINE, isnull(i.gdgid2,d.GDGID) gdgid,
	          		CASES, isnull(d.QTY * i.relqty, d.qty) qty,
	          		DMDCASES, isnull(d.DMDQTY * i.relqty, d.dmdqty) dmdqty,
	          		NOTE, CHECKED, INV, BCKEDQTY
	          	from NBCKDMDDTL d, invchg i
			where d.SRC = @src_id AND ID = @bill_id and d.gdgid *= i.gdgid

			update bckdmddtl set CASES = qty / qpc, dmdcases = dmdqty / qpc
			from goods g(nolock)
			where g.gid = bckdmddtl.gdgid and bckdmddtl.num = (select num from NBCKDMD where SRC = @src_id AND ID = @bill_id)
			and bckdmddtl.gdgid in (select gdgid2 from invchg(nolock))
		end
		else
	   		insert into bckdmddtl (NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE,CHECKED, INV, BCKEDQTY)
	          	select NUM, LINE, GDGID, CASES, QTY, DMDCASES, DMDQTY, NOTE,CHECKED, INV, BCKEDQTY     --FDY 2003.11.26 1422
	          	from nbckdmddtl
			where SRC = @src_id AND ID = @bill_id
		if @@error <> 0
		begin
			set @MSG = '接收'+@NET_NUM+'单据失败'
			return(1)
		end
	end
	--Receive Bill Over
	EXEC BCKDMDADDLOG @net_num, @net_stat, '接收', @OPER

	--Receive NBckDmdSplitDtl
	exec @ret = RcvBckdmdSplit @src_id, @bill_id, @oper, @msg output
	if @ret <> 0
	  return(@ret)
	--over

	--检查是否某个来源单据拆分后都被发送回门店了TODISCCUSS
	--Check Out SrcNum
	if exists(select 1 from vdrbckdmd where num like @num)
	begin
		update bckdmd set
		    stat = 1400,
		    LstUpdTime = GetDate()
		where num in(
			select srcnum from BckDmdSplitDtl
			where newnum = @num and newcls = 'VDRBCKDMD' and srccls = 'BCKDMD')
	end
	--开始自动生成退货单  --ShenMin 如果启用新退货流程，就不能用AutoGenStkInBck自动生成退货单
	if (@AutoGenBckBill = 1) and ((select Optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'UseNewAlcBckFlow')) <> 1)
	begin
		if (@UserProperty <> 16) and (@net_stat = 400) and (@net_dmdstore = @UserGid)
		begin
			exec @ret = AutoGenStkInBck @net_num, @Message output
			set @msg = @Message
		end
	END

       --ShenMin
	if ((select Optionvalue from hdoption where (moduleno = 0) and (optioncaption = 'UseNewAlcBckFlow')) = 1)
	  and ((select stat FROM NBCKDMD where SRC = @src_id AND ID = @bill_id) = 3100)
	begin
		INSERT INTO BCKDMDDTLDTL(NUM, LINE, CASENUM, GDGID, CASES, QTY)
		SELECT NUM, LINE, CASENUM, GDGID, CASES, QTY
		FROM NBCKDMDDTLDTL
		WHERE SRC = @src_id AND ID = @bill_id

		--根据箱号自动生成退货单
		exec @ret = autogenstkoutbckbycases @net_num, @Message output
		set @msg = @Message
	end
	delete from nbckdmd where ID = @bill_id and SRC = @src_id
	delete from nbckdmddtl where ID = @bill_id and SRC = @src_id
	delete from nbckdmddtldtl where ID = @bill_id and SRC = @src_id  --ShenMin
	return(@ret)
END
GO
