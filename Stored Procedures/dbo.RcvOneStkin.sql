SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvOneStkin](
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
	       @inprc money,
	       @rtlprc money,
	       @cost money, --added by wang xin 2003.02.13
               @validdate datetime,
               @wrh int,
               @subwrh int,		/* 2000.12.6 */
               @return_status int,
               @cur_settleno int,
	       @stat smallint,
               @ErrMsg varchar(100),
               @N_Num char(10),
               @N_Checker int,
	       @Checker int,
               @N_NOTE varchar(100),    /*2002-01-22*/
	       @optvalue smallint,
		@sNewFlag smallint,
		@cur_YearSettle smallint
	declare	@UseInvChgRelQty smallint,     --慈客隆定制
		@lit_wrh int, @lit_qpc money, @relqty money

   	exec optreadint 0,'UseInvChgRelQty',0,@UseInvChgRelQty output

     select @return_status = 0
     select @cur_settleno = MAX(NO) from MONTHSETTLE
     select @cur_YearSettle = MAX(NO) from YEARSETTLE
     select @N_Num = NUM, @N_Checker = CHECKER, @stat = STAT
     from NSTKOUT where SRC = @src_id and ID = @bill_id

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

     select @Checker = b.GID from EMPXLATE a, EMPLOYEEH b
     where a.NGID = @N_Checker and a.LGID = b.GID
     if @@rowcount = 0 or @Checker is null
     begin
             select @Errmsg = '网络单据' + @N_Num + '的审核人的员工资料尚未转入'
             raiserror(@Errmsg, 16, 1)
             return(1)
     end

     insert into STKIN ( CLS, NUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE,
          TOTAL, TAX, NOTE, FILDATE, FILLER, CHECKER, STAT, MODNUM, PSR,
          RECCNT, SRC, SRCNUM, SNDTIME, PAYDATE, ORDNUM, WRH)
          select @cls, @num, @cur_settleno, @src_id, OTHERSIDENUM, @src_id, OCRDATE,
                 TOTAL, TAX, NOTE, FILDATE, @Checker, @operator, 0, null, 1,
                 RECCNT, @src_id, NUM, null, PAYDATE, SRCORDNUM, 1
          from NSTKOUT where ID = @bill_id and SRC = @src_id
     if @@error <> 0 return(@@error)

     exec OPTREADINT 70, 'GetWrhMode', 0, @optvalue output  /*2002-05-09*/

     declare c_NSTKOUTDTL cursor for
           select LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,
           SUBWRH/* 2000.12.6 */,NOTE/*2002-01-22*/
           from NSTKOUTDTL where ID = @bill_id and SRC = @src_id

     open c_NSTKOUTDTL
     fetch next from c_NSTKOUTDTL into
           @line, @gdgid, @cases, @qty, @price, @total, @tax, @validdate, @wrh,
           @subwrh/* 2000.12.6 */,@N_NOTE

     while @@fetch_status = 0
     begin
     	--为慈客隆定制 Fanduoyi
     	--大->小
	if @UseInvChgRelQty = 1 and exists(select 1 from invchg(nolock) where gdgid = @gdgid)
	begin
		select @relqty = relqty, @gdgid = gdgid2 from invchg where gdgid = @gdgid
		select @lit_qpc = qpc, @lit_wrh = wrh from goods(nolock) where gid = @gdgid
 		select @qty = @relqty * @qty
 		select @cases = @qty / @lit_qpc, @price = @total / @qty
 	end
	 select @lgid = null
	 select @inprc = a.INPRC, @rtlprc = a.RTLPRC, @lgid = a.GID
	 from GOODSH a, GDXLATE b
	where b.NGID = @gdgid and b.LGID = a.GID
         if @@rowcount = 0 or @lgid is null
         begin
                select @Errmsg = '网络单据' + @N_Num + '中第'
                       + convert(varchar, @line) + '行的商品资料尚未转入'
                raiserror(@Errmsg, 16, 1)
                select @return_status = 1
                break
         end

         if  not ((@cls = '配货') and (@optvalue = 1)) /*2002-05-09*/
         begin
            if @wrh = 1 select @wrh = WRH from GOODS where GID = @lgid
         end

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
	 	if not exists(select 1 from inyrpt where asettleno = @cur_YearSettle and bgdgid = @lgid)
	     set @sNewFlag = 1

		 /* 2000.12.6 */
		 if ((select BATCHFLAG from SYSTEM) = 1) or ((select BATCHFLAG from SYSTEM) = 2)
	         insert into STKINDTL ( CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, LOSS,
                PRICE, TOTAL, TAX, VALIDDATE, WRH, BCKQTY, PAYQTY, INPRC, RTLPRC,
                SUBWRH, NOTE/*2002-01-22*/, sNewFlag)
    	     values (@cls, @cur_settleno, @num, @line, @lgid, @cases, @qty, 0,
			 @price, @total, @tax, @validdate, @wrh, 0, 0, @inprc, @rtlprc,
		 	 @subwrh, @N_NOTE, @sNewFlag)
		 else
	         insert into STKINDTL ( CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, LOSS,
                PRICE, TOTAL, TAX, VALIDDATE, WRH, BCKQTY, PAYQTY, INPRC, RTLPRC, NOTE/*2002-01-22*/, sNewFlag)
    	     values (@cls, @cur_settleno, @num, @line, @lgid, @cases, @qty, 0,
			 @price, @total, @tax, @validdate, @wrh, 0, 0, @inprc, @rtlprc, @N_NOTE, @sNewFlag)
         if @@error <> 0
         begin
           select @return_status = @@error
           break
         end
         fetch next from c_NSTKOUTDTL into
               @line, @gdgid, @cases, @qty, @price, @total, @tax, @validdate, @wrh,
               @subwrh /* 2000.12.6 */,@N_NOTE
     end


     close c_NSTKOUTDTL
     deallocate c_NSTKOUTDTL

    -- Added by ShenMin, 2008.01.15
    -- Q10070: 增加数据完整性校验

     DECLARE @fromBillRecordCount int
     DECLARE @netBillRecordCount int

     SELECT @fromBillRecordCount = RECCNT FROM STKIN WHERE SRCNUM = @num AND SRC = @src_id AND CLS = @cls

     SELECT @netBillRecordCount = Count(1) FROM NSTKOUTDTL WHERE ID = @bill_id

     IF @fromBillRecordCount <> @netBillRecordCount
     BEGIN
       SELECT @Errmsg = '接收的目的单据中的明细数与网络表中的明细数不符。'
       RAISERROR (@Errmsg, 16, 1)
     END

     if (select BATCHFLAG from system ) = 2
     begin
     declare c_NSTKOUTDTL2 cursor for
           select LINE, SUBWRH, WRH, GDGID, QTY, COST
           from NSTKOUTDTL2 where ID = @bill_id and SRC = @src_id
     open c_NSTKOUTDTL2
     fetch next from c_NSTKOUTDTL2 into
           @line, @subwrh, @wrh, @gdgid, @qty, @cost

     while @@fetch_status = 0
     begin
	 select @lgid = null
	 select @lgid = a.GID
	 from GOODSH a, GDXLATE b
	 where b.NGID = @gdgid and b.LGID = a.GID
         if @@rowcount = 0 or @lgid is null
         begin
                select @Errmsg = '网络单据' + @N_Num + '中第'
                       + convert(varchar, @line) + '行的商品资料尚未转入'
                raiserror(@Errmsg, 16, 1)
                select @return_status = 1
                break
         end

         if (@wrh = 1)  and (@optvalue = 0) select @wrh = WRH from GOODS where GID = @lgid

	 insert into STKINDTL2 ( CLS, NUM, LINE, SUBWRH, WRH, GDGID, QTY, COST)
    	     values (@cls, @num, @line, @subwrh, @wrh, @lgid, @qty, @cost)

         if @@error <> 0
         begin
                    select @return_status = @@error
                    break
         end
         fetch next from c_NSTKOUTDTL2 into
               @line, @subwrh, @wrh, @gdgid, @qty, @cost
     end
     close c_NSTKOUTDTL2
     deallocate c_NSTKOUTDTL2
     end

     if (select rstwrh from system) = 1
     begin
       if (
         select count(distinct wrh) from stkindtl
         where cls = @cls and num = @num
       ) > 1
       begin
         select @errmsg = '网络单据' + @n_num + '中存在不同仓位的商品'
         raiserror(@errmsg, 16, 1)
         return(1)
       end
       update stkin set wrh =
         (select min(wrh) from stkindtl where cls = @cls and num = @num)
         where cls = @cls and num = @num
     end

     return(@return_status)
end
GO
