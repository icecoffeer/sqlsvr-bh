SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CstMizeChk_confirm] 
	@num char(10),
	@curdate datetime,
	@cursettleno int,
	@errmsg varchar(200)='' output
as
begin
	declare
		@ret_status int,
		@LINE int, @GDGID int, @QTY money, @TOTAL money, @TAX money,
                @WRH int, @SUBWRH int, @INPRC money, @RTLPRC money, 
                @payrate money, @sale smallint, @gdinprc money,
		@store int, @curtime datetime, @billto int, @vdr int, @slr int

        select @ret_status = 0
        select @billto = billto, @vdr = vendor, @slr = slr from Cstmize where num = @num
        select @store = UserGid from system

	declare c_csm cursor for
		select	LINE, GDGID, QTY, TOTAL, TAX, WRH, INPRC, RTLPRC
		from CstMizeDTL 
		where NUM = @num
	open c_csm
	fetch next from c_csm into 
		@LINE, @GDGID, @QTY, @TOTAL, @TAX, @WRH, @INPRC, @RTLPRC
	while @@fetch_status = 0 begin
            select @inprc = INPRC, @rtlprc = RTLPRC, @payrate = PAYRATE, @sale = SALE
                from GOODSH where GID = @gdgid

            if @sale = 2
            begin 
                select @curtime = getdate()
                execute @ret_status=GetGoodsPrmInprc @store, @gdgid, @curtime, @qty, @inprc output
                if @ret_status <> 0             
                select @inprc = INPRC from GOODSH where GID = @gdgid
                select @ret_status = 0 
            end

           if @sale = 3 select @inprc = @total / @qty * @payrate / 100

           update CSTMIZEDTL set INPRC = @inprc, RTLPRC = @rtlprc
              where NUM = @num and LINE = @line

           if (@subwrh is not null) 
           begin
                execute @ret_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @qty
                if @ret_status <> 0 return(@ret_status)
           end
           execute @ret_status = UNLOAD @wrh, @gdgid, @qty, @rtlprc, null
           if @ret_status <> 0 return(@ret_status)

           insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
                           WC_Q, WC_A, WC_T, WC_I, WC_R)
              values (@curdate, @cursettleno, @wrh, @gdgid, @billto, @slr, @vdr,
                      @qty, @total-@tax, @tax, @qty * @inprc, @qty * @rtlprc)
          if @@error <> 0 
          begin
              select @ret_status = 201
              return(@ret_status)
          end  

           /*代销商品若进行促销进价促销，生成调价差异 2001-06-04*/
           if @sale = 2
           begin
              select @gdinprc = inprc from goodsh where gid = @gdgid
              if @inprc <> @gdinprc
                 insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
                    values (@cursettleno, @curdate, @gdgid, @wrh,
                           (@inprc-@gdinprc) * @qty)
              if @@error <> 0 
              begin
                 select @ret_status = 202
                 return(@ret_status)
              end
   
           end

           fetch next from c_csm into 
		    @LINE, @GDGID, @QTY, @TOTAL, @TAX, @WRH, @INPRC, @RTLPRC
	end
        close c_csm
	deallocate c_csm
     
        return(@ret_status)       
end
GO
