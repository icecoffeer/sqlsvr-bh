SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvOneDirAlc](
	@cls char(10),
        @num char(10),
        @bill_id int,
        @src_id int,
        @operator int
) with encryption as
begin
     declare
                @lgid int,
                @line smallint,
                @gdgid int,
                @cases money,
                @qty money,
                @total money,
                @tax money,
                @price money,
		@alcprc money,
		@alcamt money,	
                @validdate datetime,
                @wrh int,
		@bnum char(10),
		@wsprc money,
		@inprc money,
		@rtlprc money,
                @return_status int,
                @cur_settleno int,
	        @stat smallint,	
                @ErrMsg varchar(100),
                @N_Num char(10),
                @N_Checker int,
		@N_Vendor int,
		@Vendor int,
		@Checker int,
		@outtax money,
		@subwrh int,
		@subwrhcode char(10),
		@cost money,
		@sNewFlag smallint,
		@cur_YearSettle smallint

     select @return_status = 0
     select @cur_settleno = MAX(NO) from MONTHSETTLE
     select @cur_YearSettle = MAX(NO) from YEARSETTLE
     set @snewFlag = 0
     select @N_Num = NUM, @N_Checker = CHECKER, @stat = STAT, @N_Vendor = VENDOR
     from NDIRALC where SRC = @src_id and ID = @bill_id

     if @stat not in (1, 2, 6) 
     begin
	  	select @Errmsg = '网络单据' + @N_Num + '是不可接收单据'
		raiserror(@Errmsg, 16, 1)
		return(1)
     end	
	
     if not exists (select GID from STORE where GID = @src_id)
     begin
             select @Errmsg = '网络单据' + @N_Num + '的来源单位的资料尚未转入'
             raiserror(@Errmsg, 16, 1)
             return(1)
     end

     select @Vendor = b.GID from VDRXLATE a, VENDORH b 
     where a.NGID = @N_Vendor and a.LGID = b.GID
     if @@rowcount = 0
     begin
             select @Errmsg = '网络单据' + @N_Num + '的供应商资料尚未转入'
             raiserror(@Errmsg, 16, 1)
             return(1)
     end

     select @Checker = b.GID from EMPXLATE a, EMPLOYEEH b 
     where a.NGID = @N_Checker and a.LGID = b.GID 
     if @@rowcount = 0
     begin
             select @Errmsg = '网络单据' + @N_Num + '的审核人的员工资料尚未转入'
             raiserror(@Errmsg, 16, 1)
             return(1)
     end
     /*2001-04-02  by CQH*/
     select @wrh = diralcwrh from system
     if not exists(select 1 from warehouse where gid = @wrh)
	select @wrh = 1
     insert into DIRALC ( CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, OCRDATE, PSR,
	  TOTAL, TAX, ALCTOTAL, STAT, SRC, SRCNUM, SNDTIME, NOTE, RECCNT, FILLER, 
	  CHECKER, MODNUM, VENDORNUM, FILDATE, WRH, SRCORDNUM, OUTTAX, PAYDATE, FROMNUM, FROMCLS, VERIFIER, TAXRATELMT, DEPT)  --2002-06-07 Ysp 2002060663069
          select @cls, @num, @cur_settleno, @Vendor, SENDER, RECEIVER, OCRDATE, 1,
                 TOTAL, TAX, ALCTOTAL, 0, @src_id, NUM, null, NOTE, RECCNT, @checker, 
		 @operator, null, VENDORNUM, FILDATE, @wrh, ORDNUM, OUTTAX, PAYDATE, FROMNUM, FROMCLS, VERIFIER, TAXRATELMT, DEPT  --ShenMin
          from NDIRALC where ID = @bill_id and SRC = @src_id
     if @@error <> 0 return(@@error)

     declare c_NDIRALCDTL cursor for
           select LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, ALCPRC, ALCAMT, VALIDDATE, WRH, BNUM, OUTTAX, COST
           from NDIRALCDTL where ID = @bill_id and SRC = @src_id

     open c_NDIRALCDTL
     fetch next from c_NDIRALCDTL into
           @line, @gdgid, @cases, @qty, @price, @total, @tax, @alcprc, @alcamt, @validdate, @wrh, @bnum, @outtax,@cost

     while @@fetch_status = 0
     begin
	 select @inprc = a.INPRC, @rtlprc = a.RTLPRC, @wsprc = a.WHSPRC, @lgid = a.GID
	 from GOODSH a, GDXLATE b 
	 where b.NGID = @gdgid and b.LGID = a.GID

         if @@rowcount = 0
         begin
                select @Errmsg = '网络单据' + @N_Num + '中第'
                       + convert(varchar, @line) + '行的商品资料尚未转入'
                raiserror(@Errmsg, 16, 1)
                select @return_status = 1
                break
         end

         if @wrh = 1 select @wrh = WRH from GOODS where GID = @lgid

         if not exists (select * from VDRGD
         where VDRGID = @src_id and GDGID = @lgid and WRH = @wrh)
         begin
           /* 如果VDRGD中不存在对应的关系 */
           if (select RSTWRH from SYSTEM) = 1
           begin
             /* 当SYSTEM.RSTWRH=1时,拒绝接收 */
             select @Errmsg = '网络单据' + @N_Num + '中第'
               + convert(varchar, @line) +
               '行的商品不是该单据的供应商提供或不属于指定的仓位'
             raiserror(@Errmsg, 16, 1)
             select @return_status = 1
             break
           end
           else
           begin
             /* 当SYSTEM.RSTWRH=0时,加入VDRGD */
             insert into VDRGD(VDRGID, GDGID, WRH)
             values (@src_id, @lgid, @wrh)
           end
         end
	 
	 --Fanduoyi
	 set @sNewFlag = 0
	 if rtrim(@cls) = '直配进'
	   if not exists(select 1 from inyrpt where asettleno = @cur_YearSettle and bgdgid = @lgid)
	     set @sNewFlag = 1
         insert into DIRALCDTL ( CLS, NUM, LINE, SETTLENO, GDGID, WRH, CASES, QTY, LOSS,
		PRICE, TOTAL, TAX, ALCPRC, ALCAMT	, WSPRC, INPRC, RTLPRC, VALIDDATE, BNUM, OUTTAX, COST, sNewFlag)
         values( @cls, @num, @line, @cur_settleno, @lgid, @wrh, @cases, @qty, 0,
		@price, @total, @tax, @alcprc, @alcamt, @wsprc, @inprc, @rtlprc, @validdate, @bnum, @outtax, @COST, @sNewFlag)

         if @@error <> 0
         begin
                    select @return_status = @@error
                    break
         end
         fetch next from c_NDIRALCDTL into
           @line, @gdgid, @cases, @qty, @price, @total, @tax, @alcprc, @alcamt, @validdate, @wrh, @bnum, @outtax, @cost
     end

     close c_NDIRALCDTL
     deallocate c_NDIRALCDTL

     if (select BATCHFLAG from SYSTEM ) = 2
     begin
     declare c_NDIRALCDTL2 cursor for
           select LINE, GDGID, SUBWRH, SUBWRHCODE, WRH,  QTY, COST
           from NDIRALCDTL2 where ID = @bill_id and SRC = @src_id

     open c_NDIRALCDTL2
     fetch next from c_NDIRALCDTL2 into
           @line, @gdgid, @subwrh, @subwrhcode, @wrh, @qty, @cost

     while @@fetch_status = 0
     begin
	 select @lgid = a.GID
	 from GOODSH a, GDXLATE b 
	 where b.NGID = @gdgid and b.LGID = a.GID

--         if @@rowcount = 0
         if not exists (select 1 from GOODSH a, GDXLATE b where b.NGID = @gdgid and b.LGID = a.GID)
         begin

                select @Errmsg = '网络单据' + @N_Num + '中第'
                       + convert(varchar, @line) + '行的商品资料尚未转入'
                raiserror(@Errmsg, 16, 1)
                select @return_status = 1
                break
         end

         if @wrh = 1 select @wrh = WRH from GOODS where GID = @lgid

         insert into DIRALCDTL2 ( CLS, NUM, LINE, SUBWRH, WRH, GDGID,  QTY, COST)
         values( @cls, @num, @line,  @subwrh, @wrh, @lgid,  @qty, @cost)
		 
		 if @subwrh is not null
		 begin
		 	if not exists(select 1 from subwrh where GID = @SUBWRH)
		 	 	insert into subwrh(GID, CODE, NAME, INPRC, WRH)
		 	 		values(@SUBWRH, @SUBWRHCODE, @SUBWRHCODE, @cost/@qty, 1)
		 	update DIRALCDTL set SUBWRH = @subwrh where cls = @cls and num = @num and line = @line
		 end 
         if @@error <> 0
         begin
                    select @return_status = @@error
                    break
         end
         fetch next from c_NDIRALCDTL2 into
           @line, @gdgid, @subwrh, @subwrhcode, @wrh, @qty, @cost
     end
     close c_NDIRALCDTL2
     deallocate c_NDIRALCDTL2
     end
     return(@return_status)
end
GO
