SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CstMizeChk_gathering] 
	@num char(10),
        @neg int,  ---1=收款  -1=取消收款
	@curdate datetime,
	@cursettleno int,
	@errmsg varchar(200)='' output
as
begin
	declare
		@ret_status int,
		@LINE int, @GDGID int, @QTY money, @TOTAL money, @WRH2 int, @INPRC money, @RTLPRC money, 
		@wrh int, @curtime datetime, @billto int, @prepay money

        select @ret_status = 0
        select @billto = billto, @wrh = wrh, @prepay = Prepay from Cstmize where num = @num

        if @neg = -1
           Update CstMize set stat = 11, Gathdate = null, Cashier = 1
              where num = @num 

	declare c_csm cursor for
		select	LINE, GDGID, QTY, Total, WRH, INPRC, RTLPRC
		from CstMizeDTL 
		where NUM = @num
	open c_csm
	fetch next from c_csm into 
		@LINE, @GDGID, @QTY, @Total, @WRH2, @INPRC, @RTLPRC
	while @@fetch_status = 0 begin
           insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
                           SK_Q, SK_A, SK_I, SK_R)
                 values (@curdate, @cursettleno, @billto, @gdgid, @wrh2,
                         @neg*@qty, @neg*@total, @neg*@qty*@inprc, @neg*@qty*@rtlprc)
           fetch next from c_csm into 
		    @LINE, @GDGID, @QTY, @Total, @WRH2, @INPRC, @RTLPRC

           if @@error <> 0 
           begin
             select @ret_status = 301
             return(@ret_status)
           end
	end
        close c_csm
	deallocate c_csm

        insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
                        SK_Q, SK_A, SK_I, SK_R)
        values (@curdate, @cursettleno, @billto, 1, @wrh,
                0, -@neg*@prepay, 0, 0)
      
        if @@error <> 0 select @ret_status = 302
        return(@ret_status)       

end
GO
