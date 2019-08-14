SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[RATEDLTNUM]
	@old_num char(10),
	@new_oper int,
	@new_num char(10)
as
begin
	declare @cur_settleno int,
		@STORE INT,
		@cur_STORE INT,
		@cur_DATE DATETIME,
		@SETTLENO INT,
		@DATE DATETIME,
		@VDRGID INT,
		@WRH   INT,
		@GDGID INT,
		@QTY   MONEY,
		@DT1  MONEY,
		@DT2  MONEY,
		@DT3 MONEY

	select  @cur_settleno = max(NO) from MONTHSETTLE
	select  @cur_STORE = usergid from SYSTEM
	select  @cur_Date = convert(datetime,convert(char(10),getdate(),102),102)
	--生成新的单据
	insert into SVI(cls, num,settleno,filDate,filler,checker,wrh,billto,
			BPayDate,EPayDate,AMT,SAMT,Stat,modNum,Note,prntime)
	select '联销', @new_num,@cur_settleNo,getdate(),@new_oper,@new_oper,wrh,billto,
		 	BPayDate,EPayDate,-AMT,-SAMT,4,@old_num,note,null
	from SVI where num = @old_num and cls = '联销'
	insert into SVIPayStoreDtl(cls, num, StoreGid)
	select '联销', @new_num,StoreGid from SVIPayStoreDtl where num = @old_num and cls = '联销'

	insert into SVIDTL(cls, num, line,settleno,gdgid,qty,total,stotal,BPayDate,EPayDate,
		Inprc,RtlPrc,Tax)
	select '联销', @new_num,line,@cur_settleNo,gdgid,-qty,-total,-stotal,BPayDate,EPayDate,
		Inprc,RtlPrc,-Tax
	from SVIDTL where num = @old_num and cls = '联销'
	insert into SVIDTLDTL(cls, num,line,item,store,settleno,date,vdrgid,wrh,gdgid,qty,DT1,DT2,DT3,ISPAY)
	select '联销', @new_num,line,item,store,settleno,date,vdrgid,wrh,gdgid,-qty,-DT1,-DT2,-DT3,ISPAY
	from SVIDTLDTL where Num = @old_num and cls = '联销'
	
	--added by wang xin 2002.12.02 
	insert into SVITCDTL(CLS, NUM, LINE, TCCLS, TCCODE)
	  select '联销', @new_num, LINE, TCCLS, TCCODE 
	  from SVITCDTL where NUM = @old_num and CLS = '联销'
	--added end
	
	--更新原有单据
	update SVI set stat = 2, modnum = @new_num where num = @old_num and cls = '联销'
	--回写到OSBAL 表中
	declare DTLDTL_CURSOR cursor for
	SELECT STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,DT3 FROM SVIDTLDTL WHERE NUM= @OLD_NUM and CLS = '联销' AND ISPAY = 0
	OPEN DTLDTL_CURSOR
	fetch next FROM DTLDTL_CURSOR into @STORE,@SETTLENO,@DATE,@VDRGID,@WRH,@GDGID,@QTY,@DT1,@DT2,@DT3
	WHILE @@FETCH_STATUS = 0 
	begin
		if NOT EXISTS (SELECT * FROM OSBAL WHERE STORE = @STORE
						AND SETTLENO = @SETTLENO
						AND DATE = @DATE
						AND VDRGID = @VDRGID
						AND WRH = @WRH
						AND GDGID = @GDGID)
			insert into osbal(Store,settleno,date,vdrgid,wrh,gdgid,qty,dt1,dt2)
			select store,settleno,date,vdrgid,wrh,gdgid,qty,dt1,dt2
				from SVIDTLDTL
				where num = @old_num
					AND CLS = '联销'
					AND STORE = @STORE 
					AND SETTLENO = @SETTLENO
					AND DATE = @DATE
					AND VDRGID = @VDRGID
					AND WRH = @WRH
					AND GDGID = @GDGID
					AND ISPAY = 0
		else
			UPDATE OSBAL 
			SET QTY = QTY + @QTY,
				DT1 = DT1 + @DT1,
				DT2 = DT2 + @DT2	
			where STORE = @STORE 
					AND SETTLENO = @SETTLENO
					AND DATE = @DATE 
					AND VDRGID = @VDRGID
					AND WRH = @WRH
					AND GDGID = @GDGID
		select @Qty = -1*@Qty
		select @DT3 = -1*@DT3
		execute AppUpdVdrDrpt @cur_STORE, @cur_Settleno, @cur_Date, @VdrGid, @Wrh, @GDGid, 0, 0, 0, @Qty, 0, 0, 0, 0, 0, @DT3, 0, 0, 0, 0
/*		if not exists(select 1 from vdrdrpt where AStore = @Cur_Store and ASettleno = @cur_Settleno and
			ADate = @cur_Date and BVdrGid = @VdrGid and BWrh = @Wrh and BGDGid = @GDGid)
		begin
			insert into vdrdrpt(AStore, ASettleno, ADate, BVdrGid, BWrh, BGDGid, Dq4, Dt4)
			values(@cur_STORE,@cur_Settleno,@cur_Date,@VdrGid,@Wrh,@GDGid,-1*@Qty,-1*@DT3)
		end
		else begin
			update vdrdrpt set Dq4 = Dq4 - @qty, Dt4 = Dt4 - @Dt3 where AStore = @Cur_Store and ASettleno = @cur_Settleno and
			ADate = @cur_Date and BVdrGid = @VdrGid and BWrh = @Wrh and BGDGid = @GDGid
		end
*/
   		fetch next FROM DTLDTL_CURSOR into @STORE,@SETTLENO,@DATE,@VDRGID,@WRH,@GDGID,@QTY,@DT1,@DT2,@DT3
	end
	close DTLDTL_CURSOR
	deallocate DTLDTL_CURSOR		
end
GO
