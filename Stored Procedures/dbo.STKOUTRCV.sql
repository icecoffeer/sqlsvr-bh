SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[STKOUTRCV]
@SRC int,
@ID int,
@OPERATOR int
as
begin
	declare @N_Type smallint, @N_Stat smallint, @N_Cls char(10), @N_Num char(10),
		@N_FrcChk smallint, @N_ModNum char(10), @N_Vendor int, @N_BillTo int,
		@N_Checker int, @N_OrdNum char(10)
	declare @Cls char(10), @Stat smallint, @Num char(10), @Client int, @BillTo int,
		@Filler int, @OrdNum char(10)
	declare @N_Line smallint, @N_GdGID int, @N_Cases money, @N_Qty money, @N_Price money,
		@N_Total money, @N_Tax money, @N_ValidDate datetime, @N_Wrh int, @N_Note varchar(100)
	declare @GdGID int, @WsPrc money, @InPrc money, @RtlPrc money, @InvQty money
	declare @MonthSettleNo int, @CurId int, @CurModNum char(10), @MaxNum char(10),
		@ErrorMsg varchar(255), @PreNum char(10)
	declare @N_Subwrh int, @N_Cost money
	declare @return_status int		--2003.08.22

	select @MonthSettleNo = max(NO) from MONTHSETTLE

	select @N_Type = TYPE, @N_Stat = STAT, @N_Cls = CLS, @N_Num = NUM, @N_FrcChk = FRCCHK,
		@N_ModNum = MODNUM, @N_Vendor = VENDOR, @N_BillTo = BILLTO, @N_Checker = CHECKER,
		@N_OrdNum = ORDNUM
	from NSTKIN where SRC = @SRC and ID = @ID

	if @@ROWCOUNT = 0
	begin
		raiserror('该单据对应的配货进货单不存在', 16, 1)
		return(1)
	end

	if @N_Cls = '自营'
		select @Cls = '批发'
	if @N_Cls = '调入'
		select @Cls = '调出'
	if @N_Cls = '配货'
		select @Cls = '配货'

	if @N_Type <> 1
	begin
		raiserror('该单据不在接收缓冲区中', 16, 1)
		return(1)
	end

	if @N_Stat not in (1, 4, 6)
	begin
		raiserror('该单据不是已审核(复核)单据或负单(冲单), 不能被单独接收', 16, 1)
		return(1)
	end

	select @Stat = STAT, @Num = NUM
	from STKOUT where SRC = @SRC and CLS = @Cls and SRCNUM = @N_Num

	if @@ROWCOUNT > 0
		if (@Stat = 0 or @Stat = 7/*2001-11-05*/) and @N_FrcChk = 1
		begin
			update STKOUT
			set SETTLENO = @MonthSettleNo,
				FILDATE = getdate(),
				CHECKER = @OPERATOR
			where CLS = @CLS and NUM = @Num

			update STKOUTDTL
			set SETTLENO = @MonthSettleNo
			where CLS = @Cls and NUM = @Num

			--2003.08.22 By Ysp
			execute @return_status = STKOUTCHK @CLS = @Cls, @NUM = @Num
			if @return_status <> 0	return(1)

			delete from NSTKIN where SRC = @SRC and ID = @ID  /*2002-07-04*/

			delete from NSTKINDTL where SRC = @SRC and ID = @ID  /*2002-07-04*/
			if (select BATCHFLAG from SYSTEM) = 2
			    delete from NSTKINDTL2 where SRC = @SRC and ID = @ID
			select @CurId = max(ID), @CurModNum = max(MODNUM)
			from NSTKIN where SRC = @SRC and NUM = @N_ModNum and CLS = @N_Cls

			while @CurId is not null
			begin
				delete from NSTKIN where SRC = @SRC and ID = @CurID  /*2002-07-04*/

				delete from NSTKINDTL where SRC = @SRC and ID = @CurID  /*2002-07-04*/
				if (select BATCHFLAG from SYSTEM) = 2
			             delete from NSTKINDTL2 where SRC = @SRC and ID = @CurID
				select @CurId = max(ID), @CurModNum = max(MODNUM)
				from NSTKIN where SRC = @SRC and NUM = @CurModNum and CLS = @N_Cls
			end
			return(0)
		end
		else
		begin
			raiserror('该单据已被接收过', 16, 1)
          -- Q6402: 网络单据接收时被拒绝自动删除单据
          IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
          BEGIN
        		delete from NSTKIN where SRC = @SRC and ID = @ID
        		delete from NSTKINDTL where SRC = @SRC and ID = @ID
          END

			return(1)
		end
/*
	if @N_Stat = 4
	begin
		select @Stat = STAT, @Num = NUM
		from STKOUT where SRC = @SRC and @CLS = @Cls and SRCNUM = @N_ModNum

		if @@ROWCOUNT > 0
		begin
			if @Stat = 0
			begin
			   update STKOUT
			   set SETTLENO = @MonthSettleNo,
				   FILDATE = getdate(),
				   CHECKER = @OPERATOR
			   where CLS = @CLS and NUM = @Num

			   update STKOUTDTL
			   set SETTLENO = @MonthSettleNo
			   where CLS = @Cls and NUM = @Num

				execute STKOUTCHK @CLS = @Cls, @NUM = @Num
			end
			else
				if @Stat = 2
				begin
					raiserror('该单据所冲的单据已经被修正,不能再冲', 16, 1)
					return(1)
				end

			execute STKOUTDLT @OLD_CLS = @Cls, @OLD_NUM = @Num, @NEW_OPER = @OPERATOR

			delete from NSTKIN where SRC = @SRC and ID = @ID
			delete from NSTKINDTL where SRC = @SRC and ID = @ID

			return(0)
		end
		else
		begin
			raiserror('该单据所冲的单据从未被接收过，无法冲单', 16, 1)
			return(1)
		end
	end
*/
	if @N_Stat = 1 or @N_Stat = 6 or @N_Stat = 4
	begin
/*
		select @Client = LGID from VDRXLATE where NGID = @N_VENDOR

		if @@ROWCOUNT = 0
		begin
			raiserror('该单据的供应商资料尚未转入', 16, 1)
			return(1)
		end

		select @BillTo = LGID from VDRXLATE where NGID = @N_BillTo

		if @@ROWCOUNT = 0
		begin
			raiserror('该单据的结算单位尚未转入', 16, 1)
			return(1)
		end
*/


		if @N_Stat <> 4
		begin
			select @Filler = LGID from EMPXLATE where NGID = @N_Checker

			if @@ROWCOUNT = 0
			begin
				raiserror('该单据的审核人的员工资料尚未转入', 16, 1)
				return(1)
			end

			select @MaxNum = max(NUM) from STKOUT where CLS = @Cls
			if @MaxNum is null
				select @MaxNum = '0000000000'	--2003.02.28
			execute NEXTBN @ABN = @MaxNum, @NEWBN = @Num output

			select @OrdNum = max(NUM) from ORD where SRCNUM = @N_OrdNum

			insert into STKOUT (CLS, SRCNUM, NUM, SETTLENO, CLIENT, BILLTO, OCRDATE, TOTAL,
				TAX, WRH, NOTE, FILDATE, CHECKER, FILLER, STAT, MODNUM, RECCNT, SLR, SRC,
				SNDTIME, ORDNUM, SRCORDNUM, PAYDATE)
			select @Cls, NUM, @Num, @MonthSettleNo, SRC, SRC, OCRDATE, TOTAL,
				TAX, 1, NOTE, FILDATE, @OPERATOR, @Filler, 0, MODNUM, RECCNT, 1, SRC,
				null, @OrdNum, @N_OrdNum, PAYDATE
			from NSTKIN where SRC = @SRC and ID = @ID

			declare Cursor1 cursor for
				select LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH, NOTE/*2002-01-22*/,COST
				from NSTKINDTL where SRC = @SRC and ID = @ID
			for read only

			open Cursor1
			fetch next from Cursor1 into @N_Line, @N_GdGID, @N_Cases, @N_Qty, @N_Price,
				@N_Total, @N_Tax, @N_ValidDate, @N_Wrh, @N_NOTE, @N_Cost
			while @@FETCH_STATUS = 0
			begin
				select @GdGID = LGID from GDXLATE where NGID = @N_GdGID

				if @@ROWCOUNT = 0
				begin
					select @ErrorMsg = '该单据第' + convert(varchar, @N_Line)
						+ '行的商品资料尚未转入'
					raiserror(@ErrorMsg, 16, 1)
					break
				end

				select @InvQty = isnull((select QTY from V_INV
				where GDGID = @GdGID and WRH = @N_Wrh), 0)

				select @WsPrc = WHSPRC, @InPrc = INPRC, @RTLPRC = RTLPRC
				from GOODS where GID = @GdGID

				insert into STKOUTDTL (CLS, NUM, SETTLENO, LINE, GDGID, CASES, QTY, WSPRC,
					PRICE, TOTAL, TAX, VALIDDATE, WRH, INPRC, RTLPRC, INVQTY, NOTE,COST/*2002-01-22*/)
				values(@Cls, @Num, @MonthSettleNo, @N_Line, @GdGID, @N_Cases, @N_Qty, @WsPrc,
					@N_Price, @N_Total, @N_Tax, @N_ValidDate, @N_Wrh, @InPrc, @RtlPrc, @InvQty, @N_NOTE, @N_Cost)

				fetch next from Cursor1 into @N_Line, @N_GdGID, @N_Cases, @N_Qty, @N_Price,
					@N_Total, @N_Tax, @N_ValidDate, @N_Wrh, @N_NOTE, @N_Cost
			end
			close Cursor1
			deallocate Cursor1

      -- Added by zhourong, 2006.05.10
      -- Q6669: 增加数据完整性校验
      DECLARE @fromBillRecordCount int
      DECLARE @netBillRecordCount int
      SELECT @fromBillRecordCount = RECCNT FROM STKOUT WHERE SRCNUM = @N_num AND SRC = @SRC AND CLS = @cls

      SELECT @netBillRecordCount = Count(1) FROM NSTKINDTL WHERE ID = @ID

      IF @fromBillRecordCount <> @netBillRecordCount
      BEGIN
        SELECT @errormsg = '接收的目的单据中的明细数与网络表中的明细数不符。'
        RAISERROR (@errormsg, 16, 1)
      END

			declare Cursor2 cursor for
				select LINE, GDGID, SUBWRH, WRH,  QTY, COST
				from NSTKINDTL2 where SRC = @SRC and ID = @ID
			for read only

			open Cursor2
			fetch next from Cursor2 into @N_Line, @N_GdGID, @N_SUBWRH, @N_Wrh, @N_Qty, @N_COST
			while @@FETCH_STATUS = 0
			begin
				select @GdGID = LGID from GDXLATE where NGID = @N_GdGID

				if @@ROWCOUNT = 0
				begin
					select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
						+ @N_Num + '的第' + convert(varchar, @N_Line)
						+ '行的商品资料尚未转入'
					raiserror(@ErrorMsg, 16, 1)
					return(1)
				end

				insert into STKOUTDTL2 (CLS, NUM, LINE, GDGID, SUBWRH, WRH, QTY,COST)
				values(@Cls, @Num, @N_Line, @GdGID, @N_SubWrh, @N_Wrh, @N_Qty,@N_Cost)

				fetch next from Cursor2 into @N_Line, @N_GdGID, @N_Subwrh, @N_Wrh, @N_Qty, @N_Cost
			end
			close Cursor2
			deallocate Cursor2

			if @N_FrcChk = 1
				--2003.08.22 By Ysp
				execute @return_status = STKOUTCHK @CLS = @Cls, @NUM = @Num
				if @return_status <> 0	return(1)

			select @PreNum = @Num
		end
		else
			select @PreNum = null


		delete from NSTKIN where SRC = @SRC and ID = @ID
		delete from NSTKINDTL where SRC = @SRC and ID = @ID
		if (select BATCHFLAG from SYSTEM) = 2
			    delete from NSTKINDTL2 where SRC = @SRC and ID = @ID
		if @N_ModNum is null or @N_ModNum = ''
			return(0)

		select @CurId = @ID
		select @CurModNum = @N_ModNum

		while @CurModNum is not null and @CurModNum <> ''
		begin
			select @CurId = max(ID), @CurModNum = max(MODNUM)
			from NSTKIN where SRC = @SRC and NUM = @CurModNum and CLS = @N_Cls

			if @CurId is null
			begin
				raiserror('接收缓冲区中以该单据开始的修正链不完整，无法接收', 16, 1)
				return(1)
			end

			select @N_Num = NUM, @N_Vendor = VENDOR, @N_BillTo = BILLTO,
				@N_Checker = CHECKER
			from NSTKIN where SRC = @SRC and ID = @CurId

			select @Stat = STAT, @Num = NUM
			from STKOUT where SRC = @SRC and CLS = @Cls and SRCNUM = @N_Num

			if @@ROWCOUNT > 0
			begin
				if @Stat = 0 or @Stat = 7/*2001-11-05*/
				begin
					update STKOUT
					set SETTLENO = @MonthSettleNo,
						FILDATE = getdate(),
						CHECKER = @OPERATOR
					where CLS = @CLS and NUM = @Num

					update STKOUTDTL
					set SETTLENO = @MonthSettleNo
					where CLS = @Cls and NUM = @Num

					--2003.08.22 By Ysp
					execute @return_status = STKOUTCHK @CLS = @Cls, @NUM = @Num
					if @return_status <> 0	return(1)

				end
					if @Stat = 2
					begin
						select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
							+ @N_Num + '对应的本地单据已经被修正，修正链无法被整体转入'
						raiserror(@ErrorMsg, 16, 1)
						return(1)
					end
				--2003.08.22 By Ysp
				execute @return_status = STKOUTDLT @OLD_CLS = @Cls, @OLD_NUM = @Num,
					@NEW_OPER = @OPERATOR
				if @return_status <> 0 return(1)

                if @N_Num <> @N_ModNum
					update STKOUT
					set STAT = 3
					where CLS = @Cls and NUM =
						(select max(NUM) from STKOUT where STAT = 4 and MODNUM = @Num)

				update STKOUT
				set MODNUM = @Num
				where CLS = @Cls and NUM = @PreNum


				delete from NSTKIN where SRC = @SRC and ID = @CurID

				delete from NSTKINDTL where SRC = @SRC and ID = @CurID
				if (select BATCHFLAG from SYSTEM) = 2
			    		delete from NSTKINDTL2 where SRC = @SRC and ID = @CurID
				return(0)
			end

/*
			select @Client = LGID from VDRXLATE where NGID = @N_VENDOR

			if @@ROWCOUNT = 0
			begin
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的供应商资料尚未转入'
				raiserror(@ErrorMsg, 16, 1)
				return(1)
			end

			select @BillTo = LGID from VDRXLATE where NGID = @N_BillTo

			if @@ROWCOUNT = 0
			begin
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的结算单位资料尚未转入'
				raiserror(@ErrorMsg, 16, 1)
				return(1)
			end
*/
			select @Filler = LGID from EMPXLATE where NGID = @N_Checker

			if @@ROWCOUNT = 0
			begin
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的审核人的员工资料尚未转入'
				raiserror(@ErrorMsg, 16, 1)
				return(1)
			end

			select @MaxNum = max(NUM) from STKOUT where CLS = @Cls
			if @MaxNum is null
				select @MaxNum = '0000000000'   --2003.02.28
			execute NEXTBN @ABN = @MaxNum, @NEWBN = @Num output

			select @OrdNum = max(NUM) from ORD where SRCNUM = (
				select ORDNUM from NSTKIN where SRC = @SRC and ID = @CurID)

			insert into STKOUT (CLS, SRCNUM, NUM, SETTLENO, CLIENT, BILLTO, OCRDATE, TOTAL,
				TAX, WRH, NOTE, FILDATE, CHECKER, FILLER, STAT, MODNUM, RECCNT, SLR, SRC,
				SNDTIME, ORDNUM, SRCORDNUM, PAYDATE)
			select @Cls, NUM, @Num, @MonthSettleNo, SRC, SRC, OCRDATE, TOTAL,
				TAX, 1, NOTE, FILDATE, @OPERATOR, @Filler, 0, MODNUM, RECCNT, 1, SRC,
				null, @OrdNum, ORDNUM, PAYDATE
			from NSTKIN where SRC = @SRC and ID = @CurId

			declare Cursor1 cursor for
				select LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH, NOTE/*2002-01-22*/,COST
				from NSTKINDTL where SRC = @SRC and ID = @CurID
			for read only

			open Cursor1
			fetch next from Cursor1 into @N_Line, @N_GdGID, @N_Cases, @N_Qty, @N_Price,
				@N_Total, @N_Tax, @N_ValidDate, @N_Wrh, @N_NOTE, @N_Cost
			while @@FETCH_STATUS = 0
			begin
				select @GdGID = LGID from GDXLATE where NGID = @N_GdGID

				if @@ROWCOUNT = 0
				begin
					select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
						+ @N_Num + '的第' + convert(varchar, @N_Line)
						+ '行的商品资料尚未转入'
					raiserror(@ErrorMsg, 16, 1)
					return(1)
				end

				select @WsPrc = WHSPRC, @InPrc = INPRC, @RTLPRC = RTLPRC
				from GOODS where GID = @GdGID

				select @InvQty = isnull((select QTY from V_INV
					where GDGID = @GdGID and WRH = @N_Wrh), 0)

				insert into STKOUTDTL (CLS, NUM, SETTLENO, LINE, GDGID, CASES, QTY,
					WSPRC, PRICE, TOTAL, TAX, VALIDDATE, WRH, INPRC, RTLPRC, INVQTY, NOTE/*2002-01-22*/,COST)
				values(@Cls, @Num, @MonthSettleNo, @N_Line, @GdGID, @N_Cases, @N_Qty,
					@WsPrc, @N_Price, @N_Total, @N_Tax, @N_ValidDate, @N_Wrh, @InPrc,
					@RtlPrc, @InvQty, @N_NOTE, @N_Cost)

				fetch next from Cursor1 into @N_Line, @N_GdGID, @N_Cases, @N_Qty, @N_Price,
					@N_Total, @N_Tax, @N_ValidDate, @N_Wrh, @N_NOTE, @N_Cost
			end
			close Cursor1
			deallocate Cursor1

      -- Added by zhourong, 2006.05.10
      -- Q6669: 增加数据完整性校验
      SELECT @fromBillRecordCount = RECCNT FROM STKOUT WHERE SRCNUM = @N_num AND SRC = @SRC AND CLS = @cls

      SELECT @netBillRecordCount = Count(1) FROM NSTKINDTL WHERE ID = @CurID

      IF @fromBillRecordCount <> @netBillRecordCount
      BEGIN
        SELECT @errormsg = '接收的目的单据中的明细数与网络表中的明细数不符。'
        RAISERROR (@errormsg, 16, 1)
      END

			declare Cursor2 cursor for
				select LINE, GDGID, SUBWRH, WRH,  QTY, COST
				from NSTKINDTL2 where SRC = @SRC and ID = @CurID
			for read only

			open Cursor2
			fetch next from Cursor2 into @N_Line, @N_GdGID, @N_SUBWRH, @N_Wrh, @N_Qty, @N_COST
			while @@FETCH_STATUS = 0
			begin
				select @GdGID = LGID from GDXLATE where NGID = @N_GdGID

				if @@ROWCOUNT = 0
				begin
					select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
						+ @N_Num + '的第' + convert(varchar, @N_Line)
						+ '行的商品资料尚未转入'
					raiserror(@ErrorMsg, 16, 1)
					return(1)
				end

				insert into STKOUTDTL2 (CLS, NUM, LINE, GDGID, SUBWRH, WRH, QTY,COST)
				values(@Cls, @Num, @N_Line, @GdGID, @N_SubWrh, @N_Wrh, @N_Qty,@N_Cost)

				fetch next from Cursor2 into @N_Line, @N_GdGID, @N_Subwrh, @N_Wrh, @N_Qty, @N_Cost
			end
			close Cursor2
			deallocate Cursor2


			--2003.08.22 By Ysp
			execute @return_status = STKOUTCHK @CLS = @Cls, @NUM = @Num
			if @return_status <> 0	return(1)


			execute @return_status = STKOUTDLT @OLD_CLS = @Cls, @OLD_NUM = @Num,
					@NEW_OPER = @OPERATOR
			if @return_status <> 0	return(1)

			if @N_Num <> @N_ModNum
				update STKOUT
				set STAT = 3
				where CLS = @Cls and NUM =
					(select max(NUM) from STKOUT where STAT = 4 and MODNUM = @Num)

			update STKOUT
			set MODNUM = @Num
			where CLS = @Cls and NUM = @PreNum

			delete from NSTKIN where SRC = @SRC and ID = @CurID
			delete from NSTKINDTL where SRC = @SRC and ID = @CurID
			if (select BATCHFLAG from SYSTEM) = 2
			    delete from NSTKINDTL2 where SRC = @SRC and ID = @CurID
			select @PreNum = @Num
		end
	end
end
GO
