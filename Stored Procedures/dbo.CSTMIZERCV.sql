SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CSTMIZERCV]
@SRC int,
@ID int,
@OPERATOR int
as
begin
	declare @N_Type smallint, @N_Stat smallint, @N_Num char(10),@N_SRC int, @N_SRCNum char(10),
		@N_ModNum char(10), @N_Vendor int, @N_BillTo int, @N_Client int, @N_Receiver int,
		@N_Filler int, @N_Checker int, @N_Confirmer int, @N_Slr int, @N_FINISHED smallint, @N_CFMDATE Datetime,
                @N_TOTAL money, @N_TAX money, @N_GTOTAL money, @N_NOTE varchar(255), @N_RECCNT SMALLINT
	declare @Stat smallint, @Num char(10), @Client int, @BillTo int, @Vendor int, @Receiver int,
		@Filler int,@Checker int, @Confirmer int, @Slr int, @FINISHED smallint, @SRCNUM char(10), @WRH smallint
	declare @N_Line smallint, @N_GdGID int, @N_GQTY money, @N_Qty money, @N_Price money
	declare @GdGID int, @InPrc money, @RtlPrc money
	declare @MonthSettleNo int, @CurId int, @CurModNum char(10), @MaxNum char(10),
		@ErrorMsg varchar(255), @PreNum char(10), @CFMBYSELF smallint
        declare @ret_Status int, @NewNum char(10), @store int

        select @ret_status = 0 
	select @MonthSettleNo = max(NO) from MONTHSETTLE
        select @CFMBYSELF = CfmBySelf, @Store = UserGID from system

	select @N_Type = TYPE, @N_Stat = STAT, @N_Num = NUM, @N_FINISHED = FINISHED, @N_SRC = SRC, @N_SRCNum = SRCNUM,
		@N_ModNum = MODNUM, @N_Vendor = VENDOR, @N_CLIENT = CLIENT, @N_BillTo = BILLTO, 
                @N_Filler = FILLER, @N_Checker = CHECKER, @N_CONFIRMER = CONFIRMER, @N_SLR = SLR, @N_CFMDATE = CFMDATE,
                @N_total = Total, @N_Tax = Tax, @N_Gtotal = Gtotal, @N_Note = Note, @N_Reccnt = reccnt
	from NCSTMIZE where SRC = @SRC and ID = @ID

	if @@ROWCOUNT = 0
	begin
		raiserror('该单据不存在', 16, 1)
		return(1)
	end

	if @N_Type <> 1
	begin
		raiserror('该单据不在接收缓冲区中', 16, 1)
		return(1)
	end

	select @Filler = LGID from EMPXLATE where NGID = @N_Filler
	if @@ROWCOUNT = 0
	begin
                Update NcstMize set NNote = '该单据的填单人的员工资料尚未转入'
                       where SRC = @SRC and ID = @ID
		return(1)
	end

	select @Checker = LGID from EMPXLATE where NGID = @N_Checker
	if @@ROWCOUNT = 0
	begin
                Update NcstMize set NNote = '该单据的审核人的员工资料尚未转入'
                       where SRC = @SRC and ID = @ID
		return(1)
	end

        if @N_Confirmer <> 1
        begin
 	     select @Confirmer = LGID from EMPXLATE where NGID = @N_Confirmer
	     if @@ROWCOUNT = 0
	     begin
                     Update NcstMize set NNote = '该单据的批准人的员工资料尚未转入'
                       where SRC = @SRC and ID = @ID
		     return(1)
	     end
        end

        if @N_Slr <> 1
        begin
             select @Slr = LGID from EMPXLATE where NGID = @N_Slr
	     if @@ROWCOUNT = 0
	     begin
                     Update NcstMize set NNote = '该单据的销售员的员工资料尚未转入'
                       where SRC = @SRC and ID = @ID
		     return(1)
	     end
        end

	select @Vendor = LGID from VDRXLATE where NGID = @N_Vendor
	if @@ROWCOUNT = 0
	begin
                Update NcstMize set NNote = '该单据的供货单位资料尚未转入'
                       where SRC = @SRC and ID = @ID
		return(1)
	end

	select @Client = LGID from CLNXLATE where NGID = @N_Client
	if @@ROWCOUNT = 0
	begin
                Update NcstMize set NNote = '该单据的客户资料尚未转入'
                       where SRC = @SRC and ID = @ID
		return(1)
	end

	select @Billto= LGID from CLNXLATE where NGID = @N_Billto
	if @@ROWCOUNT = 0
	begin
                Update NcstMize set NNote = '该单据的结算单位的客户资料尚未转入'
                       where SRC = @SRC and ID = @ID
		return(1)
	end

	declare Cursor1 cursor for
		select LINE, GDGID
		from NCSTMIZEDTL where SRC = @SRC and ID = @ID
	for read only
	open Cursor1
	fetch next from Cursor1 into @N_Line, @N_GdGID
	while @@FETCH_STATUS = 0
	begin
		select @GdGID = LGID from GDXLATE where NGID = @N_GdGID

		if @@ROWCOUNT = 0
		begin
			select @ErrorMsg = '该单据第' + convert(varchar, @N_Line)
				+ '行的商品资料尚未转入'
                        Update NcstMize set NNote = @ErrorMsg
                               where SRC = @SRC and ID = @ID
			return(1)
		end
		fetch next from Cursor1 into @N_Line, @N_GdGID
	end
	close Cursor1
	deallocate Cursor1

        if @CFMBYSELF = 1
        begin
        	if @N_Stat <> 10 and @N_FINISHED <> 0
                begin
                        Update NcstMize set NNote = '该单据不待批准单据, 不能被接收'
                              where SRC = @SRC and ID = @ID
	        	return(501)
                end
        end 
        else if @CFMBYSELF = 0
             begin
                  if  @N_stat <> 11 and @N_Stat <> 4 and (not (@N_stat = 10 and @N_finished = 1))
                   begin
                        Update NcstMize set NNote = '该单据不是已批准、已作废单据或冲单(负单), 不能被接收'
                              where SRC = @SRC and ID = @ID
         		return(501)
                   end 
             end
   
        if @CFMBYSELF = 1
        begin
            select @Stat = STAT, @Num = NUM, @Finished = Finished
	        from CSTMIZE where SRC = @SRC and SRCNUM = @N_Num

       	    if @@ROWCOUNT > 0
            begin
               if @Stat = 10 and @Finished = 0
	       begin
                        Update NcstMize set NNote = '该单据已被接收过'
                              where SRC = @SRC and ID = @ID
              -- Q6402: 网络单据接收时被拒绝自动删除单据
              IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
              BEGIN
                	 delete from NCSTMIZE where SRC = @SRC and ID = @ID
                 delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
              END

			return(1)
               end
               if @Stat = 10 and @Finished = 1
	       begin
                        Update NcstMize set NNote = '该单据已被作废，不能再次接收'
                              where SRC = @SRC and ID = @ID
			return(1)
               end
               if @Stat <> 10
	       begin
                        Update NcstMize set NNote = '该单据已被批准，不能再次接收'
                              where SRC = @SRC and ID = @ID
			return(1)
               end
            end
            else
            begin
	         select @MaxNum = max(NUM) from CSTMIZE
		 if @MaxNum is null
			select @MaxNum = '0000000000'
		 execute NEXTBN @ABN = @MaxNum, @NEWBN = @Num output

                 insert into CSTMIZE (NUM, SETTLENO, VENDOR, CLIENT, BILLTO, RECEIVER,
                        WRH, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, GATHDATE,
                        FILLER, CHECKER, CONFIRMER, CASHIER, SLR, STAT, MODNUM, RECCNT, SRC, SRCNUM, FINISHED)
                 select @num, @MonthSettleNo, VENDOR, CLIENT, BILLTO, RECEIVER,
                        1, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, NULL,
                        FILLER, CHECKER, CONFIRMER, 1, slr, STAT, MODNUM, RECCNT, SRC, NUM, FINISHED
                   from NCSTMIZE where SRC = @SRC and ID = @ID

                 insert into CSTMIZEDTL (SETTLENO, NUM, LINE, GDGID, GQTY, QTY, 
                        PRICE, GTOTAL, TOTAL, TAX, WRH, INPRC, RTLPRC, SUBWRH)
                 select @MonthSettleNo, @num, LINE, GDGID, GQTY, QTY,
                        PRICE, GTOTAL, TOTAL, TAX, 1, INPRC, RTLPRC, SUBWRH
                   from NCSTMIZEDTL where SRC = @SRC and ID = @ID

                if exists(select * from NBILLAPDX
	              where ID = @id and SRC = @SRC and BILL = 'NCSTMIZE')
                begin
		      delete from BILLAPDX where BILL = 'CSTMIZE' and NUM = @num

  		      insert into BILLAPDX(BILL, CLS, NUM, FILDATE, DSPMODE, DSPDATE,
  			   OUTCTR, OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			   INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE)
		      select 'CSTMIZE', '', @NUM, FILDATE, DSPMODE, DSPDATE,
	       		   OUTCTR, OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			   INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE
	       	       from NBILLAPDX
		       where ID = @id and SRC = @SRC and BILL = 'NCSTMIZE'

		      delete from NBILLAPDX
        	      where ID = @id and SRC = @SRC and BILL = 'NCSTMIZE'
               end

            	 delete from NCSTMIZE where SRC = @SRC and ID = @ID
                 delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
                 return(0)
            end
        end

        if (@CFMBYSELF = 0) and (@N_stat = 10 and @N_finished = 1)
        begin
            if exists (select 1 from CSTMIZE where NUM = @N_SRCNum and stat=10)
            begin
               if (select finished from CSTMIZE where NUM = @N_SRCNum) = 0
               begin
                 Update CSTMIZE set SRC = @N_SRC, SRCNUM = @N_NUM, Finished = 1 where NUM = @N_SRCNum
            	 delete from NCSTMIZE where SRC = @SRC and ID = @ID
                 delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
                 return(0)                
               end
               else
               begin
                 Update NcstMize set NNote = '本地对应的待批准定制单已经作废，不能再次接收'
                        where SRC = @SRC and ID = @ID
		 return(1)
               end
            end
            else
            begin
                 Update NcstMize set NNote = '本地未找到对应的待批准定制单，不能接收'
                        where SRC = @SRC and ID = @ID
		 return(1)
            end
        end

        if (@CFMBYSELF = 0) and (@N_stat = 11)
        begin
            select @Stat = STAT, @Num = NUM, @Finished = Finished, @SRCNUM = SRCNUM, @Wrh = Wrh
	        from CSTMIZE where NUM = @N_SRCNUM and Stat=10 and Finished = 0

       	    if @@ROWCOUNT > 0
            begin
                      Update CstMize set SettleNo = @MonthSettleNo, Vendor = @N_Vendor, Total = @N_Total, Tax = @n_tax, Gtotal = @N_Gtotal,
                                         Note = @N_Note, CfmDate = @N_CfmDate, ConFirmer = @N_ConFirmer, Reccnt = @N_Reccnt
--                                         SRC = @N_SRC, SRCNUM = @N_NUM
                             Where num = @num

                      Delete from CstMizeDtl where NUM = @NUM
                      Insert into CstMizeDtl
                      Select @NUM, @MonthSettleNo, LINE, GDGID, GQTY, QTY, PRICE, GTOTAL, TOTAL, 
                             TAX, @Wrh, INPRC, RTLPRC, SUBWRH, NOTE
                          from NCSTMIZEDTL where NUM = @N_NUM

                      execute @ret_Status = CSTMIZECHK @NUM, 2

                      if @ret_Status <> 0 
                      begin
                           Update NcstMize set NNote = '接收已批准单据失败'
                               where SRC = @SRC and ID = @ID
		           return(1)                          
                      end
                      else
                      begin
                          Update CstMize set  SRC = @N_SRC, SRCNUM = @N_NUM  Where num = @num

      	                  select @CurId = @ID
	                  select @CurModNum = ModNum from NCSTMIZE where SRC = @SRC and ID = @ID

          	          while @CurModNum is not null and @CurModNum <> ''
	                  begin
                 		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		                       from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 
                                  if @CurId is not null
                                  begin
                            	        delete from NCSTMIZE where SRC = @SRC and ID = @CurID
                                        delete from NCSTMIZEDTL where SRC = @SRC and ID = @CurID
                                  end   
                          end

                  	  delete from NCSTMIZE where SRC = @SRC and ID = @ID
                          delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID

                          return(0) 
                      end
            end

            select @Stat = STAT, @Num = NUM, @SRCNUM = SRCNUM, @Wrh = Wrh
	        from CSTMIZE where SRCNUM = @N_NUM and SRC = @N_SRC and Stat in (11,12) 

       	    if @@ROWCOUNT > 0
            begin
                 Update NcstMize set NNote = '该单据已接收过，不能再次接收'
                      where SRC = @SRC and ID = @ID
              -- Q6402: 网络单据接收时被拒绝自动删除单据
              IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
              BEGIN
                	 delete from NCSTMIZE where SRC = @SRC and ID = @ID
                 delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
              END

		 return(1)                          
            end

	    if @N_ModNum is null or @N_ModNum = ''
		return(0)

 	    select @CurId = @ID
	    select @CurModNum = @N_ModNum

 	    while @CurModNum is not null and @CurModNum <> ''
	    begin
		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		    from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 

		  if @CurId is null
		  begin
                        Update NcstMize set NNote = '接收缓冲区中以该单据开始的修正链不完整，无法接收'
                             where SRC = @SRC and ID = @CurID
			return(1)
		  end

 	          select @N_Num = NUM, @N_SRC = SRC, @N_SRCNum = SRCNUM,
		         @N_Vendor = VENDOR,  @N_CONFIRMER = CONFIRMER, @N_CFMDATE = CFMDATE,
                         @N_total = Total, @N_Tax = Tax, @N_Gtotal = Gtotal, @N_Note = Note, @N_Reccnt = reccnt                        
	            from NCSTMIZE where SRC = @SRC and ID = @CurID

                 if @N_Confirmer <> 1
                 begin
 	               select @Confirmer = LGID from EMPXLATE where NGID = @N_Confirmer
	               if @@ROWCOUNT = 0
	               begin
                                Update NcstMize set NNote = '批准人资料尚未转入'
                                     where SRC = @SRC and ID = @CurID
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的批准人资料尚未转入'
 		                return(1)
	               end
                 end

                 if @N_Vendor <> 1
                 begin
 	               select @Vendor = LGID from VDRXLATE where NGID = @N_Vendor
	               if @@ROWCOUNT = 0
	               begin
                                Update NcstMize set NNote = '供货单位资料尚未转入'
                                     where SRC = @SRC and ID = @CurID
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的供货单位资料尚未转入'
 		                return(1)
	               end
                 end

                 select @Stat = STAT, @Num = NUM, @Finished = Finished, @SRCNUM = SRCNUM, @Wrh = Wrh
	             from CSTMIZE where NUM = @N_SRCNUM and Stat=10 and Finished = 0

        	 if @@ROWCOUNT > 0
                 begin
                          Update CstMize set SettleNo = @MonthSettleNo, Vendor = @N_Vendor, Total = @N_Total, Tax = @n_tax, Gtotal = @N_Gtotal,
                                             Note = @N_Note, CfmDate = @N_CfmDate, ConFirmer = @N_ConFirmer, Reccnt = @N_Reccnt
                                 Where num = @num

                          Delete from CstMizeDtl where NUM = @NUM
                          Insert into CstMizeDtl
                          Select @NUM, @MonthSettleNo, LINE, GDGID, GQTY, QTY, PRICE, GTOTAL, TOTAL, 
                                 TAX, @Wrh, INPRC, RTLPRC, SUBWRH, NOTE
                              from NCSTMIZEDTL where NUM = @N_NUM

                          execute @ret_Status = CSTMIZECHK @NUM, 2
                          if @ret_Status <> 0 
                          begin
                               Update NcstMize set NNote = '接收已批准单据(审核)失败'
                                     where SRC = @SRC and ID = @CurID
		               return(1)                          
                          end

                          if @N_CONFIRMER <> 1
                                 execute @ret_Status = CSTMIZEDLT @NUM, @CONFIRMER
                          else
                                 execute @ret_Status = CSTMIZEDLT @NUM, 1

                          if @ret_Status <> 0 
                          begin
                               Update NcstMize set NNote = '接收已批准单据(冲单)失败'
                                     where SRC = @SRC and ID = @CurID
		               return(1)                          
                          end

                          Update CstMize set  SRC = @N_SRC, SRCNUM = @N_NUM  Where num = @num

                          Update Cstmize set stat=3
                                 where num = (select max(num) from cstmize where modnum=@num and stat=4)

  			  select @MaxNum = max(NUM) from CSTMIZE
			  if @MaxNum is null
			  	  select @MaxNum = '0000000000'
			  execute NEXTBN @ABN = @MaxNum, @NEWBN = @NewNum output

                          insert into CSTMIZE (NUM, SETTLENO, VENDOR, CLIENT, BILLTO, RECEIVER,
                                  WRH, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, GATHDATE,
                                  FILLER, CHECKER, CONFIRMER, CASHIER, SLR, STAT, MODNUM, RECCNT, SRC, SRCNUM, FINISHED)
                          select @newnum, @MonthSettleNo, VENDOR, CLIENT, BILLTO, RECEIVER,
                                  @WRH, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, NULL,
                                  FILLER, CHECKER, CONFIRMER, 1, slr, 0, @NUM, RECCNT, /*SRC, NUM,*/@Store, null, FINISHED
                              from NCSTMIZE where SRC = @SRC and ID = @ID

                          insert into CSTMIZEDTL (SETTLENO, NUM, LINE, GDGID, GQTY, QTY, 
                                  PRICE, GTOTAL, TOTAL, TAX, WRH, INPRC, RTLPRC, SUBWRH)
                          select @MonthSettleNo, @newnum, LINE, GDGID, GQTY, QTY,
                                  PRICE, GTOTAL, TOTAL, TAX, @WRH, INPRC, RTLPRC, SUBWRH
                              from NCSTMIZEDTL where SRC = @SRC and ID = @ID


                          execute @ret_Status = CSTMIZECHK @NEWNUM, 3
                          if @ret_Status <> 0 
                          begin
                               Update NcstMize set NNote = '接收已批准单据失败'
                                     where SRC = @SRC and ID = @ID
		               return(1)                          
                          end

                          Update CstMize set  SRC = @SRC, SRCNUM = (select NUM From NCSTMIZE  Where SRC = @SRC and ID = @ID)
                                 where num = @NewNum

                          update BILLAPDX set NUM = @newnum
                             where BILL = 'CSTMIZE' and NUM = @num

      	                  select @CurId = @ID
	                  select @CurModNum = ModNum from NCSTMIZE where SRC = @SRC and ID = @ID

          	          while @CurModNum is not null and @CurModNum <> ''
	                  begin
                 		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		                       from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 
                                  if @CurId is not null
                                  begin
                            	        delete from NCSTMIZE where SRC = @SRC and ID = @CurID
                                        delete from NCSTMIZEDTL where SRC = @SRC and ID = @CurID
                                  end   
                          end

                       	  delete from NCSTMIZE where SRC = @SRC and ID = @ID
                          delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
                          return(0)

                end

                select @Stat = STAT, @Num = NUM, @SRCNUM = SRCNUM, @Wrh = Wrh
	              from CSTMIZE where SRCNUM = @N_NUM and SRC = @N_SRC and Stat=11 

       	        if @@ROWCOUNT > 0
                begin
                          if @N_CONFIRMER <> 1
                                 execute @ret_Status = CSTMIZEDLT @NUM, @CONFIRMER
                          else
                                 execute @ret_Status = CSTMIZEDLT @NUM, 1

                          if @ret_Status <> 0 
                          begin
                               Update NcstMize set NNote = '接收已批准单据(冲单)失败'
                                     where SRC = @SRC and ID = @CurID
		               return(1)                          
                          end

                          Update Cstmize set stat=3
                                 where num = (select max(num) from cstmize where modnum=@num and stat=4)

  			  select @MaxNum = max(NUM) from CSTMIZE
			  if @MaxNum is null
			  	  select @MaxNum = '0000000000'
			  execute NEXTBN @ABN = @MaxNum, @NEWBN = @NewNum output

                          insert into CSTMIZE (NUM, SETTLENO, VENDOR, CLIENT, BILLTO, RECEIVER,
                                  WRH, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, GATHDATE,
                                  FILLER, CHECKER, CONFIRMER, CASHIER, SLR, STAT, MODNUM, RECCNT, SRC, SRCNUM, FINISHED)
                          select @newnum, @MonthSettleNo, VENDOR, CLIENT, BILLTO, RECEIVER,
                                  @WRH, TOTAL, TAX, GTOTAL, PREPAY, NOTE, FILDATE, CHKDATE, CFMDATE, NULL,
                                  FILLER, CHECKER, CONFIRMER, 1, slr, 0, @NUM, RECCNT, /*SRC, NUM,*/@store, null, FINISHED
                              from NCSTMIZE where SRC = @SRC and ID = @ID

                          insert into CSTMIZEDTL (SETTLENO, NUM, LINE, GDGID, GQTY, QTY, 
                                  PRICE, GTOTAL, TOTAL, TAX, WRH, INPRC, RTLPRC, SUBWRH)
                          select @MonthSettleNo, @newnum, LINE, GDGID, GQTY, QTY,
                                  PRICE, GTOTAL, TOTAL, TAX, @WRH, INPRC, RTLPRC, SUBWRH
                              from NCSTMIZEDTL where SRC = @SRC and ID = @ID


                          execute @ret_Status = CSTMIZECHK @NEWNUM, 3
                          if @ret_Status <> 0 
                          begin
                               Update NcstMize set NNote = '接收已批准单据失败'
                                     where SRC = @SRC and ID = @ID
		               return(1)                          
                          end

                          Update CstMize set  SRC = @SRC, SRCNUM = (select NUM From NCSTMIZE  Where SRC = @SRC and ID = @ID)
                                 where num = @NewNum

                          update BILLAPDX set NUM = @newnum
                             where BILL = 'CSTMIZE' and NUM = @num

      	                  select @CurId = @ID
	                  select @CurModNum = ModNum from NCSTMIZE where SRC = @SRC and ID = @ID

          	          while @CurModNum is not null and @CurModNum <> ''
	                  begin
                 		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		                       from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 
                                  if @CurId is not null
                                  begin
                            	        delete from NCSTMIZE where SRC = @SRC and ID = @CurID
                                        delete from NCSTMIZEDTL where SRC = @SRC and ID = @CurID
                                  end   
                          end

                       	  delete from NCSTMIZE where SRC = @SRC and ID = @ID
                          delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
                          return(0)

                end

                select @Stat = STAT, @Num = NUM, @SRCNUM = SRCNUM, @Wrh = Wrh
	              from CSTMIZE where SRCNUM = @N_NUM and SRC = @N_SRC and Stat=12
       	        if @@ROWCOUNT > 0
                begin
		        select @ErrorMsg = '本地对应单据'+ @num +'号定制单已收款，请取消收款后再尝试接收!'
                        Update NcstMize set NNote = @ErrorMsg
                                     where SRC = @SRC and ID = @CurID
			return(1)
                end 
            end

            select @ErrorMsg = '本地找不到对应单据，无法接收!'
            Update NcstMize set NNote = @ErrorMsg
                   where SRC = @SRC and ID = @ID
  	    return(1)
        end

        if (@CFMBYSELF = 0) and (@N_stat = 4)
        begin
	    if @N_ModNum is null or @N_ModNum = ''
            begin
                Update NcstMize set NNote = '冲单单据的修正链不完整，无法接收'
                   where SRC = @SRC and ID = @ID
		return(0)
            end

 	    select @CurId = @ID
	    select @CurModNum = @N_ModNum

 	    while @CurModNum is not null and @CurModNum <> ''
	    begin
		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		    from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 

		  if @CurId is null
		  begin
                        Update NcstMize set NNote = '接收缓冲区中以该单据开始的修正链不完整，无法接收'
                            where SRC = @SRC and ID = @CurID
			return(1)
		  end

 	          select @N_Num = NUM, @N_SRC = SRC, @N_SRCNum = SRCNUM,
		         @N_Vendor = VENDOR,  @N_CONFIRMER = CONFIRMER, @N_CFMDATE = CFMDATE,
                         @N_total = Total, @N_Tax = Tax, @N_Gtotal = Gtotal, @N_Note = Note, @N_Reccnt = reccnt                        
	            from NCSTMIZE where SRC = @SRC and ID = @CurID

                 if @N_Confirmer <> 1
                 begin
 	               select @Confirmer = LGID from EMPXLATE where NGID = @N_Confirmer
	               if @@ROWCOUNT = 0
	               begin
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的批准人资料尚未转入'
                                Update NcstMize set NNote = '批准人资料尚未转入'
                                    where SRC = @SRC and ID = @CurID
 		                return(1)
	               end
                 end

                 if @N_Vendor <> 1
                 begin
 	               select @Vendor = LGID from VDRXLATE where NGID = @N_Vendor
	               if @@ROWCOUNT = 0
	               begin
				select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '的供货单位资料尚未转入'
                                Update NcstMize set NNote = '供货单位资料尚未转入'
                                    where SRC = @SRC and ID = @CurID
 		                return(1)
	               end
                 end

                 select @Stat = STAT, @Num = NUM, @Finished = Finished, @SRCNUM = SRCNUM, @Wrh = Wrh
	             from CSTMIZE where NUM = @N_SRCNUM and Stat=10 and Finished = 0

        	 if @@ROWCOUNT > 0
                 begin
                          Update CSTMIZE set SRC = @N_SRC, SRCNUM = @N_NUM, Finished = 1 where NUM = @N_SRCNum 

      	                  select @CurId = @ID
	                  select @CurModNum = ModNum from NCSTMIZE where SRC = @SRC and ID = @ID

          	          while @CurModNum is not null and @CurModNum <> ''
	                  begin
                 		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		                       from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 
                                  if @CurId is not null
                                  begin
                            	        delete from NCSTMIZE where SRC = @SRC and ID = @CurID
                                        delete from NCSTMIZEDTL where SRC = @SRC and ID = @CurID
                                  end   
                          end

                       	  delete from NCSTMIZE where SRC = @SRC and ID = @ID
                          delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID

                          return(0)
                 end

                select @Stat = STAT, @Num = NUM, @SRCNUM = SRCNUM, @Wrh = Wrh
	              from CSTMIZE where SRCNUM = @N_NUM and SRC = @N_SRC and Stat=11 

       	        if @@ROWCOUNT > 0
                begin
                          if @N_CONFIRMER <> 1
                                 execute @ret_Status = CSTMIZEDLT @NUM, @CONFIRMER
                          else
                                 execute @ret_Status = CSTMIZEDLT @NUM, 1

                          if @ret_Status <> 0 
                          begin
                               Update NcstMize set NNote = '接收已批准单据(冲单)失败'
                                     where SRC = @SRC and ID = @CurID
		               return(1)                          
                          end

      	                  select @CurId = @ID
	                  select @CurModNum = ModNum from NCSTMIZE where SRC = @SRC and ID = @ID

          	          while @CurModNum is not null and @CurModNum <> ''
	                  begin
                 		  select @CurId = max(ID), @CurModNum = max(MODNUM)
		                       from NCSTMIZE where SRC = @SRC and NUM = @CurModNum 
                                  if @CurId is not null
                                  begin
                            	        delete from NCSTMIZE where SRC = @SRC and ID = @CurID
                                        delete from NCSTMIZEDTL where SRC = @SRC and ID = @CurID
                                  end   
                          end

                       	  delete from NCSTMIZE where SRC = @SRC and ID = @ID
                          delete from NCSTMIZEDTL where SRC = @SRC and ID = @ID
                          return(0)

                end

                select @Stat = STAT, @Num = NUM, @SRCNUM = SRCNUM, @Wrh = Wrh
	              from CSTMIZE where SRCNUM = @N_NUM and SRC = @N_SRC and Stat=12 
        	if @@ROWCOUNT > 0
                begin
		     select @ErrorMsg = '接收缓冲区中以该单据开始的修正链中有一张单据'
					+ @N_Num + '已进行收款，请先取消收款再尝试接收!'
                     Update NcstMize set NNote = @ErrorMsg
                            where SRC = @SRC and ID = @CurID
		     return(1)                          
                end
           end

           select @ErrorMsg = '本地找不到对应单据或本地单据已经冲单，无法接收!'
           Update NcstMize set NNote = @ErrorMsg
                  where SRC = @SRC and ID = @ID
	   return(1)                          
        end

end
GO
