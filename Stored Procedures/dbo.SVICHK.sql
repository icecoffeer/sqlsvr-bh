SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SVICHK](
	@p_num   char(10),
    @p_isWrh  smallint,
	@new_oper int
	)
as	
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
		@OptionValue char(1),
		@INV_QTY money,
		@max_date datetime,
		@max_settleno int,
		@p_wrh int

	select @stat = stat from SVI where num = @p_num and cls = '代销'
	if @stat <> 0 
	begin
		raiserror('审核的不是未审核单据',16,1)
		return(1)
	end
	if exists(select 1 from svidtl sd(nolock), goods b(nolock) where sd.gdgid = b.gid 
		and b.keeptype & 1 = 1 and b.ncanpay = 0 and b.nendtime >= getdate()
		and sd.num = @p_num and sd.cls = '代销') 
	begin
		raiserror('审核的单据中包含了试销期间不允许结算的商品', 16, 1)
		return(1)
	end
	update SVI
           set stat = 1,
	       checker = @new_oper,
	       fildate = getdate()
           where num =@p_num and cls = '代销'
	update SVIDtl
	   set RtlPrc  = b.RtlPrc,Inprc = b.Inprc 
	   from goodsH b  
	   where SVIDtl.gdgid = b.gid
              and SVIDtl.num = @p_num
              and SVIDTL.cls = '代销'
	
        exec OPTREADINT 0, 'SVICTRL', -1, @OptionValue output  
        if @optionValue ='-1' 
        begin
            raiserror('代销结算功能已被设置为禁用,不能使用代销结算', 16, 1)
            return(1)
	end
	if @optionValue <> '0' and  @optionValue<>'1' and  @optionValue <>'2' 
	begin
            raiserror('代销结算功能设置有错误，请重新设置', 16, 1)
            return(1)
	end

	IF NOT EXISTS (select 1 from SVIDtlDtl a (nolock),OSBAL b (nolock) 
	  	    where b.STORE  =  A.STORE 
			AND B.SETTLENO= A.SETTLENO
			AND B.DATE = A.DATE
			AND B.VDRGID = A.VDRGID
			AND B.WRH = A.WRH
			AND B.GDGID = A.GDGID
			AND A.NUM = @P_NUM
			AND A.CLS = '代销')
	BEGIN
		RAISERROR('此代销结算单数据已被其他代销结算单全部结算，请删除该未审核代销结算单，重新结算操作！',16,1)
		RETURN(1)
	END
			
	select  @cur_settleno = max(NO) from MONTHSETTLE
	select  @cur_STORE = usergid from SYSTEM
	select  @cur_Date = convert(datetime,convert(char(10),getdate(),102),102)
	IF (SELECT COUNT(*) FROM SVIDTLDTL (nolock) WHERE NUM = @P_NUM AND CLS = '代销') = 
		(SELECT COUNT(A.NUM) from SVIDtlDtl a (nolock) ,OSBAL b (nolock) 
	  	    where b.STORE  =  A.STORE 
			AND B.SETTLENO= A.SETTLENO
			AND B.DATE = A.DATE
			AND B.VDRGID = A.VDRGID
			AND B.WRH = A.WRH
			AND B.GDGID = A.GDGID
			AND A.NUM = @P_NUM
			AND A.CLS = '代销')
	BEGIN    ---删除或更新OSBAL相应记录
		
		DECLARE OSBAL_CURSOR CURSOR FOR
		SELECT STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,DT3 FROM SVIDTLDTL WHERE NUM= @P_NUM AND CLS = '代销'
		OPEN OSBAL_CURSOR
		FETCH NEXT FROM OSBAL_CURSOR INTO @STORE,@SETTLENO,@DATE,@VDRGID,@WRH,@GDGID,@QTY,@DT1,@DT2,@DT3
		WHILE @@FETCH_STATUS = 0 
		BEGIN

              		   SELECT @QTY_OSBAL = isnull(QTY,0) FROM OSBAL (nolock)
					 WHERE STORE = @STORE 
					  and  VDRGID = @VDRGID
					  and WRH = @WRH
					  and settleno = @settleno
  					  and date = @date	
					  and  GDGID = @GDGID


-- 	                if (@INV_QTY+@Qty) <= @Qty_OSBAL 
		        if @qty <= @qty_osbal
			begin

				IF @QTY_OSBAL = @QTY 
				BEGIN
					DELETE OSBAL 
						WHERE  STORE = @STORE
						   AND SETTLENO = @SETTLENO
						   AND DATE = @DATE
						   AND VDRGID = @VDRGID
					  	   AND WRH = @WRH
						   AND GDGID = @GDGID
				END
				ELSE
				BEGIN
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
				END

			end
			else
			begin
				CLOSE OSBAL_CURSOR
				DEALLOCATE OSBAL_CURSOR			
				raiserror('此代销结算单数据已被其他代销结算单部分结算，请删除该未审核代销结算单，重新结算操作！',16,1)
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
	  		FETCH NEXT FROM OSBAL_CURSOR INTO @STORE,@SETTLENO,@DATE,@VDRGID,@WRH,@GDGID,@QTY,@DT1,@DT2,@DT3			
		END
		CLOSE OSBAL_CURSOR
		DEALLOCATE OSBAL_CURSOR		
		
	END
	ELSE
	BEGIN
		RAISERROR('此代销结算单数据已被其他代销结算单部分结算，请删除该未审核代销结算单，重新结算操作！',16,1)
		RETURN(1)

	END
GO
