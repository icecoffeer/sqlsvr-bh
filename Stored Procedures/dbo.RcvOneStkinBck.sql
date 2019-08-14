SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvOneStkinBck](
       @cls char(10),
       @num char(10),
       @bill_id int,
       @src_id int,
       @operator int
)with encryption as
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
	       @cost money,  --added by wang xin 2003.02.13
               @validdate datetime,
               @wrh int,
               @subwrh int, --added by wang xin 2003.02.14
               @return_status int,
               @cur_settleno int,
	       @stat smallint,
               @N_Checker int,
               @N_Num char(10),
               @Errmsg varchar(100),
	       @Checker int,
	       @Note varchar(100)
	declare	@UseInvChgRelQty smallint,     --慈客隆定制
		@lit_wrh int, @lit_qpc money, @relqty money
	exec optreadint 0,'UseInvChgRelQty',0,@UseInvChgRelQty output

     select @return_status = 0
     select @cur_settleno = MAX(NO) from MONTHSETTLE
     select @N_Num = NUM, @N_Checker = CHECKER, @stat = STAT
     from NSTKOUTBCK where SRC = @src_id and ID = @bill_id

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

     insert into STKINBCK ( CLS, NUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE,
          TOTAL, TAX, NOTE, FILDATE, FILLER, CHECKER, STAT, MODNUM, PSR,
          RECCNT, SRC, SRCNUM, SNDTIME, WRH, GENCLS, GENNUM)
          select @cls, @num, @cur_settleno, @src_id, null, @src_id, OCRDATE,
                 TOTAL, TAX, NOTE, FILDATE, @checker, @operator, 0, null, 1,
                 RECCNT, @src_id, NUM, null, 1, GENCLS, GENNUM
          from NSTKOUTBCK where ID = @bill_id and SRC = @src_id
     if @@error <> 0 return(@@error)

     declare c_NSTKOUTBCKDTL cursor for
             select LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,NOTE,COST
             from NSTKOUTBCKDTL where ID = @bill_id and SRC = @src_id

     open c_NSTKOUTBCKDTL
     fetch next from c_NSTKOUTBCKDTL into
           @line, @gdgid, @cases, @qty, @price, @total, @tax, @validdate, @wrh,@Note, @cost

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
              /*2001.8.31 增加了note字段*/
           insert into STKINBCKDTL ( CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY,
                PRICE, TOTAL, TAX, VALIDDATE, WRH, INPRC, RTLPRC,NOTE,COST)
           values(@cls, @cur_settleno, @num, @line, @lgid, @cases, @qty,
		  @price, @total, @tax, @validdate, @wrh, @inprc, @rtlprc,@note, @cost)
           if @@error <> 0
           begin
                    select @return_status = @@error
                    break
           end
           fetch next from c_NSTKOUTBCKDTL into
                 @line, @gdgid, @cases, @qty, @price, @total, @tax, @validdate, @wrh,@note, @cost
     end

     close c_NSTKOUTBCKDTL
     deallocate c_NSTKOUTBCKDTL

   -- Added by ShenMin, 2008.01.15
   -- Q10070: 增加数据完整性校验

     DECLARE @fromBillRecordCount int
     DECLARE @netBillRecordCount int

     SELECT @fromBillRecordCount = RECCNT FROM STKINBCK WHERE NUM = @num AND SRC = @src_id AND CLS = @cls

     SELECT @netBillRecordCount = Count(1) FROM NSTKOUTBCKDTL WHERE ID = @bill_id

     IF @fromBillRecordCount <> @netBillRecordCount
     BEGIN
       SELECT @Errmsg = '接收的目的单据中的明细数与网络表中的明细数不符。'
       RAISERROR (@Errmsg, 16, 1)
       return(1)
     END

     if (select BATCHFLAG from SYSTEM ) = 2
     begin
     	declare c_NSTKOUTBCKDTL2 cursor for
             select LINE, SUBWRH, WRH, GDGID, QTY, COST
             from NSTKOUTBCKDTL2 where ID = @bill_id and SRC = @src_id

     open c_NSTKOUTBCKDTL2
     fetch next from c_NSTKOUTBCKDTL2 into
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

           if @wrh = 1 select @wrh = WRH from GOODS where GID = @lgid

           insert into STKINBCKDTL2 ( CLS, NUM, LINE, GDGID, SUBWRH, WRH, QTY,
                COST)
           values(@cls, @num, @line, @lgid, @subwrh, @wrh, @qty,
		  @cost)
           if @@error <> 0
           begin
                    select @return_status = @@error
                    break
           end
           fetch next from c_NSTKOUTBCKDTL2 into
                 @line, @subwrh, @wrh, @gdgid, @qty, @cost
     end

     	close c_NSTKOUTBCKDTL2
     	deallocate c_NSTKOUTBCKDTL2
     end
     return(@return_status)
end
GO
