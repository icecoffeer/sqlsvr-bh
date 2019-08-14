SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CstMizeChk_check] 
	@num char(10),
	@curdate datetime,
	@cursettleno int,
	@errmsg varchar(200)='' output
as
begin
	declare
		@ret_status int,
		@LINE int, @GDGID int, @GQTY money, @GTOTAL money, @INPRC money, @RTLPRC money, 
                @payrate money, @sale smallint,
		@store int, @wrh int, @curtime datetime, @billto int, @prepay money

        select @ret_status = 0
        select @billto = billto, @wrh = wrh, @prepay = Prepay from Cstmize where num = @num
        select @store = UserGid from system

	declare c_csm cursor for
		select	LINE, GDGID, GQTY, GTotal, INPRC, RTLPRC
		from CstMizeDTL 
		where NUM = @num
	open c_csm
	fetch next from c_csm into 
		@LINE, @GDGID, @GQTY, @GTotal, @INPRC, @RTLPRC
	while @@fetch_status = 0 begin
            select @inprc = INPRC, @rtlprc = RTLPRC, @payrate = PAYRATE, @sale = SALE
                from GOODSH where GID = @gdgid

            if @sale = 2
            begin 
                select @curtime = getdate()
                execute @ret_status=GetGoodsPrmInprc @store, @gdgid, @curtime, @Gqty, @inprc output
                if @ret_status <> 0             
                select @inprc = INPRC from GOODSH where GID = @gdgid
                select @ret_status = 0 
            end

           if @sale = 3 select @inprc = @Gtotal / @Gqty * @payrate / 100

           update CSTMIZEDTL set INPRC = @inprc, RTLPRC = @rtlprc
              where NUM = @num and LINE = @line

           fetch next from c_csm into 
		    @LINE, @GDGID, @GQTY, @GTotal, @INPRC, @RTLPRC
	end
        close c_csm
	deallocate c_csm

        insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
                        SK_Q, SK_A, SK_I, SK_R)
        values (@curdate, @cursettleno, @billto, 1, @wrh,
                0, @prepay, 0, 0)
      
        if @@error <> 0 select @ret_status = 101
        return(@ret_status)       
end
GO
