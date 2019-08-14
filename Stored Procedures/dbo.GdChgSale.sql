SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdChgSale]
  @store int,
  @settleno int,
  @gdgid int,
  @oldsale int,
  @sale int,
  @dxprc money,
  @payrate money,
  @mode int,
  --@mode 0 修改全部数据
  --@mode 1 修改本期数据
  --@mode 2 修改本期日期范围内数据
  @begindate datetime,
  @enddate datetime,
  @vdrgid int,
  @wrh int,
  @operator int
as
begin
	if @oldsale = @sale
        	return(0)
        declare @OLDSHQTY money /*原营销方式应结数*/, @OLDSHTOTAL money /*原营销方式应结额*/
        declare @NEWSHQTY money /*新营销方式应结数*/, @NEWSHTOTAL money /*新营销方式应结额*/
        declare @OLDNPQTY money /*原未结数*/, @OLDNPTOTAL money /*原未结额*/
        declare @maxnum char(10), @num char(10) /*供应商结算调整单号*/
	declare @inprc money, @rtlprc money
        declare @note1 char(4), @note2 char(4)
               
        /*不修改报表以前的数据，生成一张供应商帐款调整单*/	
        select @payrate = @payrate / 100.0
        
        if @mode = 0  /*修改所有数据*/
        begin
		select @OLDSHQTY = SUM(DQ3), @OLDSHTOTAL = SUM(DT3),
                	@NEWSHQTY = (CASE @sale
                        		WHEN 1 THEN SUM(DQ1)
                                        ELSE SUM(DQ2)
                        	     END),
                        @NEWSHTOTAL = (CASE @sale
                        			WHEN 1 THEN SUM(DT1)
                                                WHEN 2 THEN SUM(DQ2) * @dxprc
                                                ELSE SUM(DT2) * @payrate 
                        	       END)
                from VDRMRPT
                where ASTORE = @store 
                and BGDGID = @gdgid
                and BVDRGID = @vdrgid and BWRH = @wrh
        end
        else if @mode = 1 /*修改本期数据*/
        begin
		select @OLDSHQTY = DQ3, @OLDSHTOTAL = DT3,
                	@NEWSHQTY = (CASE @sale
                        		WHEN 1 THEN DQ1
                                        ELSE DQ2
                        	     END),
                        @NEWSHTOTAL = (CASE @sale
                        			WHEN 1 THEN DT1
                                                WHEN 2 THEN DQ2 * @dxprc
                                                ELSE DT2 * @payrate 
                        	       END)
                from VDRMRPT
                where ASTORE = @store 
                and ASETTLENO = @settleno
                and BGDGID = @gdgid
                and BVDRGID = @vdrgid and BWRH = @wrh
                
        end
        else /*修改本期日期范围内数据*/
        begin
        	select @OLDSHQTY = SUM(DQ3), @OLDSHTOTAL = SUM(DT3),
                	@NEWSHQTY = (CASE @sale
                        		WHEN 1 THEN SUM(DQ1)
                                        ELSE SUM(DQ2)
                        	     END),
                        @NEWSHTOTAL = (CASE @sale
                        			WHEN 1 THEN SUM(DT1)
                                                WHEN 2 THEN SUM(DQ2) * @dxprc
                                                ELSE SUM(DT2) * @payrate 
                        	       END)
                from VDRDRPT
                where ASTORE = @store 
                and ASETTLENO = @settleno
                and ADATE BETWEEN @begindate and @enddate
                and BGDGID = @gdgid
                and BVDRGID = @vdrgid and BWRH = @wrh
	end
        
	if @OLDSHQTY is NULL 
               	select @OLDSHQTY = 0
        if @OLDSHTOTAL is NULL 
              	select @OLDSHTOTAL = 0        

        if @NEWSHQTY is NULL 
               	select @NEWSHQTY = 0
        if @NEWSHTOTAL is NULL 
              	select @NEWSHTOTAL = 0        

	select @OLDNPQTY = NPQTY, @OLDNPTOTAL = NPTL
	from V_VDRYRPT
	where ASTORE = @store
        and BGDGID = @gdgid
        and BVDRGID = @vdrgid and BWRH = @wrh 

        if @OLDNPQTY is NULL 
        	select @OLDNPQTY = 0
        if @OLDNPTOTAL is NULL
        	select @OLDNPTOTAL = 0
                
        select @maxnum = isnull((select MAX(NUM) from PAYADJ), '0000000000')
	execute NEXTBN @maxnum, @num output
                                                   
        select @inprc = INPRC, @rtlprc = RTLPRC from GOODS where GID = @gdgid

        if @oldsale = 1
        	select @note1 = '经销'
        else if @oldsale = 2 
        	select @note1 = '代销'
        else 
        	select @note1 = '联销'

        if @sale = 1
        	select @note2 = '经销'
        else if @sale = 2 
        	select @note2 = '代销'
        else 
        	select @note2 = '联销'
                
        insert into PAYADJ(NUM, SETTLENO, FILDATE, FILLER, CHECKER, WRH, BILLTO, STAT, NOTE)
        values(@num, @settleno, GETDATE(), @operator, @operator, @wrh, @vdrgid, 0, '由修改商品营销方式生成 ' + @note1 + '->' + @note2)

        insert into PAYADJDTL(NUM, LINE, SETTLENo, GDGID, OQTY, OTOTAL, OSTOTAL, 
        			NQTY, NTOTAL, NSTOTAL, INPRC, RTLPRC)
        values(@num, 1, @settleno, @gdgid, @OLDNPQTY, @OLDNPTOTAL, 0,
        			@NEWSHQTY - @OLDSHQTY, @NEWSHTOTAL - @OLDSHTOTAL, 0,
                                @inprc, @rtlprc)
	execute PAYADJCHK @num
    if exists(select * from GOODS where gid = @gdgid and invprc = 0)
        	update GOODS set invprc = inprc where gid = @gdgid
    RETURN 0
end
GO
