SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RATEDTLCHK]
	@p_num   char(10),
	@new_oper int
as	
begin
	declare @stat smallint,
		@STORE INT,
		@cur_STORE INT,
		@SETTLENO INT,
		@cur_SETTLENO INT,
		@cur_DATE DATETIME,
		@DATE DATETIME,
		@VDRGID INT,
		@WRH   INT,
		@GDGID INT,
		@QTY   MONEY,
		@DT1  MONEY,
		@DT2  MONEY,
		@DT3 MONEY,
		@QTY_OSBAL MONEY,
		@INV_QTY money,
		@max_date datetime,
		@max_settleno int,
		@p_wrh int

	select @stat = stat from SVI where num = @p_num and cls = '联销'
	if @stat <> 0 
	begin
		raiserror('审核的不是未审核单据',16,1)
		return(1)
	end
	if exists(select 1 from svidtl sd(nolock), goods b(nolock) where sd.gdgid = b.gid 
		and b.keeptype & 1 = 1 and b.ncanpay = 0 and b.nendtime >= getdate()
		and sd.num = @p_num and sd.cls = '联销') 
	begin
		raiserror('审核的单据中包含了试销期间不允许结算的商品', 16, 1)
		return(1)
	end
	
	update SVI set stat = 1, checker = @new_oper, fildate = getdate() where num =@p_num and cls = '联销'
	update SVIDtl set RtlPrc  = b.RtlPrc,Inprc = b.Inprc 
	from goodsH b where SVIDtl.gdgid = b.gid and SVIDtl.num = @p_num and SVIDtl.cls = '联销'

	if NOT EXISTS (select 1 from SVIDtlDtl a (nolock),OSBAL b (nolock) 
	  	    where b.STORE  =  A.STORE 
			AND B.SETTLENO= A.SETTLENO
			AND B.DATE = A.DATE
			AND B.VDRGID = A.VDRGID
			AND B.WRH = A.WRH
			AND B.GDGID = A.GDGID
			AND A.NUM = @P_NUM
			AND A.CLS = '联销'
			AND A.ISPAY = 0)	/*IsPay=0表示结算*/
	begin
		RAISERROR('此联销结算单数据已被其他联销结算单全部结算，请删除该未审核联销结算单，重新结算操作！',16,1)
		return(1)
	end
			
	select  @cur_settleno = max(NO) from MONTHSETTLE
	select  @cur_STORE = usergid from SYSTEM
	select  @cur_Date = convert(datetime,convert(char(10),getdate(),102),102)
	if (SELECT COUNT(*) FROM SVIDTLDTL(nolock) WHERE NUM = @P_NUM AND CLS = '联销' AND ISPAY = 0) = 
		(SELECT COUNT(A.NUM) from SVIDtlDtl a (nolock) ,OSBAL b (nolock) 
	  	    where b.STORE  =  A.STORE 
			AND B.SETTLENO= A.SETTLENO
			AND B.DATE = A.DATE
			AND B.VDRGID = A.VDRGID
			AND B.WRH = A.WRH
			AND B.GDGID = A.GDGID
			AND A.NUM = @P_NUM
			AND A.CLS = '联销'
			AND A.ISPAY = 0)
	begin    ---删除或更新OSBAL相应记录		
		declare OSBAL_CURSOR cursor for
		SELECT STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,DT3 FROM SVIDTLDTL WHERE NUM= @P_NUM AND CLS = '联销' AND ISPAY = 0
		OPEN OSBAL_CURSOR
		fetch next FROM OSBAL_CURSOR into @STORE,@SETTLENO,@DATE,@VDRGID,@WRH,@GDGID,@QTY,@DT1,@DT2,@DT3
		WHILE @@FETCH_STATUS = 0 
		begin
        	SELECT @QTY_OSBAL = isnull(QTY,0) FROM OSBAL (nolock)
			WHERE STORE = @STORE 
				and VDRGID = @VDRGID
				and WRH = @WRH
				and settleno = @settleno
  				and date = @date	
				and  GDGID = @GDGID

	        if @qty <= @qty_osbal
			begin
				if @QTY_OSBAL = @QTY 
				begin
					DELETE OSBAL 
						WHERE  STORE = @STORE
						   AND SETTLENO = @SETTLENO
						   AND DATE = @DATE
						   AND VDRGID = @VDRGID
					  	   AND WRH = @WRH
						   AND GDGID = @GDGID
				end else begin
					UPDATE OSBAL 
					   SET QTY = QTY - @QTY,
					       DT1 = DT1 - @DT1,
					       DT2 = DT2 - @DT2 	 
	   				   WHERE STORE = @STORE
						   AND SETTLENO = @SETTLENO
						   AND DATE = @DATE
						   AND VDRGID = @VDRGID
					  	   AND WRH = @WRH
						   AND GDGID = @GDGID
				end
			end	else begin
				close OSBAL_CURSOR
				deallocate OSBAL_CURSOR			
				raiserror('此联销结算单数据已被其他联销结算单部分结算，请删除该未审核联销结算单，重新结算操作！',16,1)
				return(1)
			end

			execute AppUpdVdrDrpt @cur_STORE, @cur_Settleno, @cur_Date, @VdrGid, @Wrh, @GDGid, 0, 0, 0, @Qty, 0, 0, 0, 0, 0, @DT3, 0, 0, 0, 0
/*			if not exists(select 1 from vdrdrpt where AStore = @Cur_Store and ASettleno = @cur_Settleno and
				ADate = @cur_Date and BVdrGid = @VdrGid and BWrh = @Wrh and BGDGid = @GDGid)
			begin
				insert into vdrdrpt(AStore, ASettleno, ADate, BVdrGid, BWrh, BGDGid, Dq4, Dt4)
				values(@cur_STORE,@cur_Settleno,@cur_Date,@VdrGid,@Wrh,@GDGid,@Qty,@DT3)
			end
			else begin
				update vdrdrpt set Dq4 = Dq4 + @qty, Dt4 = Dt4 + @Dt3 where AStore = @Cur_Store and ASettleno = @cur_Settleno and
				ADate = @cur_Date and BVdrGid = @VdrGid and BWrh = @Wrh and BGDGid = @GDGid
			end
*/
	  		fetch next FROM OSBAL_CURSOR into @STORE,@SETTLENO,@DATE,@VDRGID,@WRH,@GDGID,@QTY,@DT1,@DT2,@DT3			
		end
		close OSBAL_CURSOR
		deallocate OSBAL_CURSOR		
	end
	else
	begin
		RAISERROR('此联销结算单数据已被其他联销结算单部分结算，请删除该未审核联销结算单，重新结算操作！',16,1)
		return(1)
	end
end
GO
