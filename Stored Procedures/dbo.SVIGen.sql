SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SVIGen](
	@p_billto int,
	@p_wrh int,
	@p_BPayDate  datetime,
	@p_EPayDate  datetime,
	@p_isWrh  smallint,
	@p_isByStore smallint,
	@p_Psrer int,
	@p_isByPsrer smallint
	)
as	 
	declare @OptionValue smallint,/*deleted by hxs 2002.09.09 char(1)*/
		@STORE  INT,
		@SETTLENO SMALLINT,
		@DATE DATETIME,
		@WRH	INT,
		@GDGID	INT,
		@QTY	money,
		@DT1	money,
		@DT2	money
 	DECLARE @INV_QTY money,
 		@sqty   money, --2002.10.16 wangxin
 		@prevdrgid int,
		@pregdgid int,
 		@tmpqty money,
		@gdqty money,
		@vdrgid int,--2002.10.16 wangxin 
		@sStr	Varchar(300),
		@sTmp	varchar(20) 
	create table #noaccord(
		FLAG    INT     NOT NULL,		
		STORE	INT	NOT NULL,		--店号
		SETTLENO	INT	NOT NULL,	--期号
		DATE	DATETIME	NOT NULL,	--日期
		VDRGID	INT	NOT NULL,		--结算单位
		WRH	INT	NOT NULL,		--仓位
		GDGID	INT	NOT NULL,		--商品
		QTY	MONEY	DEFAULT 0 NOT NULL,	--销售数
		DT1	MONEY	DEFAULT 0 NOT NULL,	--销售额
		DT2	MONEY	DEFAULT 0 NOT NULL,	--应结额
	)
	create table #osbal(
		STORE	INT	NOT NULL,		--店号
		SETTLENO	INT	NOT NULL,	--期号
		DATE	DATETIME	NOT NULL,	--日期
		VDRGID	INT	NOT NULL,		--结算单位
		WRH	INT	NOT NULL,		--仓位
		GDGID	INT	NOT NULL,		--商品
		QTY	MONEY	DEFAULT 0 NOT NULL,	--销售数
		DT1	MONEY	DEFAULT 0 NOT NULL,	--销售额
		DT2	MONEY	DEFAULT 0 NOT NULL,	--应结额
		CODE	VARCHAR(13) NULL,
		NAMESPEC  VARCHAR(80) NULL,
		WRHCODE VARCHAR(80) NOT NULL,
		MCODE  VARCHAR(20) NULL,
		MUNIT	VARCHAR(6),
		RTLPRC  MONEY,
		INPRC	MONEY,
		TAXRATE	MONEY
	)
	create index inx_osb on #osbal (STORE, SETTLENO, DATE, VDRGID, WRH, GDGID) --Added by wang xin 20030103
	
	CREATE TABLE #inv1 (
	[WRH] [int]  NULL ,
	[GDGID] [int] NOT NULL ,
	[QTY] [money] NOT NULL ,
	[TOTAL] [money] NOT NULL ,
	[STORE] [int]  NULL 
	)
	CREATE TABLE #inv (
	[WRH] [int]  NULL ,
	[GDGID] [int] NOT NULL ,
	[QTY] [money] NOT NULL ,
	[TOTAL] [money] NOT NULL ,
	[STORE] [int]  NULL 
	)
	CREATE TABLE #tmpinv (
	[WRH] [int]  NULL ,
	[GDGID] [int] NOT NULL ,
	[QTY] [money] NOT NULL ,
	[TOTAL] [money] NOT NULL ,
	[STORE] [int]  NULL 
	)
	
	/*2003.10.15*/
	CREATE TABLE #tmpgd (
	[GDGID] [int]  NOT NULL, 
	PRIMARY KEY (GDGID)
	)

	exec OPTREADINT 0, 'SVICTRL', -1, @OptionValue output  
        if @optionValue =-1 
        begin
            raiserror('HDOPTION表已被设置为禁用,不能使用代销结算', 16, 1)
            return(1)
	end
	if @optionValue <> 0 and  @optionValue<>1 and  @optionValue <>2 
	begin
            raiserror('HDOPTION表设置有错误，请重新设置', 16, 1)
            return(1)
	end

	/*2003.10.15*/
        INSERT INTO #tmpgd
        select distinct GDGID
        from OSBAL A,GOODSH B
        where A.GDGID = B.GID and B.SALE = 2 
          and A.VDRGID = @p_billto
          and date >= @p_BPayDate and date<= @p_EPayDate
          and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))

	if @p_isWrh =1      --仓位限制
	begin
	    if @optionValue = 0 and @p_isByStore = 1 --按门店结算 			
	    	if @p_isByPsrer = 1 
		    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE,MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			 rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D/*2003.10.15*/
            	    where A.GDGID = B.GID and B.SALE = 2 and A.Wrh = @p_wrh and A.GDGID = D.GDGID/*2003.10.15*/
            	        and B.PSR = @p_Psrer --added by wang xin 2003.05.15
            	        and B.WRH = W.GID
			and Store in (select storeGid from #store) 
                        and date >= @p_BPayDate and date<= @p_EPayDate
                        and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))
                else
                    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D
            	    where A.GDGID = B.GID and B.SALE = 2 and A.Wrh = @p_wrh AND B.WRH = W.GID and A.GDGID = D.GDGID 
			and Store in (select storeGid from #store) 
                        and date >= @p_BPayDate and date<= @p_EPayDate
                        and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))
		 --2002.10.29 Wang xin
	    else
	       if @p_isByPsrer = 1 
	            INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D
            	    where Date <=@P_EPayDate --2002.10.16 wangxin
			AND A.GDGID = B.GID and B.SALE = 2 and A.Wrh = @p_wrh and A.GDGID = D.GDGID
			AND B.WRH = W.GID
			and B.PSR = @p_Psrer --added by wang xin 2003.05.15
			and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()) )
			 --2002.10.29 Wang xin
	     else
	         INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D
            	    where Date <=@P_EPayDate --2002.10.16 wangxin            	       
			AND A.GDGID = B.GID and B.SALE = 2 and A.Wrh = @p_wrh and A.GDGID = D.GDGID
			AND B.WRH = W.GID		
			and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()) )
			 --2002.10.29 Wang xin
	end
        else
	begin
	    if @optionValue = 0 and @p_isByStore = 1 
	    	if @p_isByPsrer = 1
		    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE, 
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D
            	    where A.GDGID = B.GID and B.SALE = 2 and A.GDGID = D.GDGID
            	        and B.PSR = @p_Psrer --Added by wang xin 2003.05.15
            	        and B.WRH = W.GID
			and Store in (select storeGid from #store) 
                      	and date >= @p_BPayDate and date<= @p_EPayDate
                      	and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin
                 else
                     INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D 
            	    where A.GDGID = B.GID and B.SALE = 2 and A.GDGID = D.GDGID
            	        and B.WRH = W.GID 
			and Store in (select storeGid from #store) 
                      	and date >= @p_BPayDate and date<= @p_EPayDate
                      	and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin
	    else
	        if @p_isByPsrer = 1 
		    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D
            	    where Date <=@P_EPayDate and A.GDGID = B.GID and B.SALE = 2 and B.PSR = @p_Psrer and A.GDGID = D.GDGID
            	    AND B.WRH = W.GID
            	    and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin	
                else
                    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, MCODE, WRHCODE)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.MCODE,
			rtrim(W.NAME) + '[' + rtrim(W.CODE) + ']' WRHCODE  
            	    from OSBAL A,GOODSH B, WAREHOUSE W, #tmpgd D
            	    where Date <=@P_EPayDate and A.GDGID = B.GID and B.SALE = 2 AND B.WRH = W.GID and A.GDGID = D.GDGID
            	    and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin	
	end        

	--2002120354583 by  guoshen 从库存日报取结算区间期末库存。
	--条件增加： 期号、店号。结束
	select @settleno = no from MONTHSETTLE where BEGINDATE < @p_EPayDate  and @p_EPayDate <= ENDDATE
	select @store = usergid from system
	
        if @p_isWrh = 1  --限制到某仓位
        begin	
        	--2003.01.22 by wangxin
        	if not exists(select 1 from invdrpt a where a.bgdgid in 
        		(select distinct b.gid from  goodsH b  ,#osbal c where   b.sale = 2  and b.gid = c.gdgid )
                        and a.adate = @p_EPayDate and a.bwrh = @p_wrh  and a.asettleno = @settleno and a.astore = @store
                        group by a.bgdgid)
                begin
               		insert into #inv1 (gdgid,qty,total)
			select a.gdgid,sum(a.qty),sum(a.total)
			from inv a 
           		where a.gdgid in (select distinct b.gid from  goodsH b  ,#osbal c
                                      where   b.sale = 2  and b.gid = c.gdgid )
                           and a.wrh = @p_wrh
                        group by a.gdgid 
        	end
        	else
        	begin
        	    insert into #inv1 (gdgid,qty,total)
		    select a.bgdgid,sum(a.fq),sum(a.ft)
		    from invdrpt a 
           	    where a.bgdgid in (select distinct b.gid from  goodsH b  ,#osbal c
                                      where   b.sale = 2  and b.gid = c.gdgid )
                           and a.adate = @p_EPayDate and a.bwrh = @p_wrh  and a.asettleno = @settleno
			and a.astore = @store
                        group by a.bgdgid 
                end
        end
        else --不仓位限制
	begin
		--2003.01.22 by wang xin 
		if not exists(select 1 from invdrpt a where a.bgdgid in (select distinct b.gid from  goodsH b  ,#osbal c
                              where   b.sale = 2  and b.gid = c.gdgid ) and a.adate = @p_EPayDate and a.asettleno = @settleno
			and a.astore = @store
                        group by a.bgdgid)
                begin
                	insert into #inv1(gdgid,qty,total)
			select a.gdgid,sum(a.qty),sum(a.total)
			from inv a 
                        where a.gdgid in (select distinct b.gid from  goodsH b  ,#osbal c
                                          where   b.sale = 2  and b.gid = c.gdgid )
                        group by a.gdgid 
        	end
        	else
        	begin
			insert into #inv1(gdgid,qty,total)
			select a.bgdgid,sum(a.fq),sum(a.ft)
			from invdrpt a 
                        where a.bgdgid in (select distinct b.gid from  goodsH b  ,#osbal c
                                          where   b.sale = 2  and b.gid = c.gdgid )
                           and a.adate = @p_EPayDate and a.asettleno = @settleno
			and a.astore = @store
                        group by a.bgdgid 	
               end
        end
	--2002120354583 by  guoshen 从库存日报取结算区间期末库存。
	--条件增加： 期号、店号。 修改结束
	
	if @optionValue = 1 --负库存控制
	begin
             insert into #inv(gdgid,qty,total)
		     select gdgid,qty,total
   	                from  #inv1 
			where qty < 0 
 
	     update #inv set qty = abs(qty)	
	end
	if @optionValue = 2 --正库存控制
	begin
	
             insert into #inv(gdgid,qty,total)
		     select gdgid,qty,total
   	                from  #inv1 
			where qty > 0 
 
	end
	insert into #tmpinv(gdgid, qty, total)
		select gdgid, qty, total from #inv

	select @tmpqty = null
	select @prevdrgid = -1
        declare C_OSBAL cursor for
        select STORE,SETTLENO,DATE,WRH,GDGID,ISNULL(QTY,0),isnull(DT1,0),isnull(DT2,0), VDRGID--2002.10.16 wangxin
            from #osbal  
	    ORDER BY VDRGID DESC, SETTLENO desc ,DATE desc ,STORE desc ,WRH desc,GDGID DESC
        open C_OSBAL
        fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid--2002.10.16 wangxin
	while @@fetch_status = 0
        begin	        	
		select @inv_qty = 0
                Select @INV_QTY = ISNULL(QTY,0)
                      from #INV 
                      WHERE  GDGID = @GDGID 
		select @INV_QTY = ISNULL(@INV_QTY,0)

		select @tmpqty = 0
                Select @tmpQTY = ISNULL(QTY,0)
                      from #tmpINV 
                      WHERE  GDGID = @GDGID 
		select @tmpQTY = ISNULL(@tmpQTY,0)
 
		if @prevdrgid <> @vdrgid 
		begin
		    select @prevdrgid = @vdrgid
			select @inv_qty = 0
                   Select @INV_QTY = ISNULL(QTY,0)
                      from #tmpINV 
                      WHERE  GDGID = @GDGID 
		    select @INV_QTY = ISNULL(@INV_QTY,0)    
		end
		
		--2002.10.16 wangxin
		select @sqty = sum(qty)
			from #osbal where GDGID = @GDGID and VDRGID = @VDRGID
		select @sqty = isnull(@sqty, 0)		
		
		 --若应结数小于等于零则不结算 --2002.10.16 wangxin
		--if @sqty = 0 		    
		--begin
		--    insert into  #noaccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
		--	values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)
		--    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                --    continue
                --end
               
               if @optionValue = 0
               begin
               	    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                    continue
               end
               		
                if @INV_QTY = 0 
		begin
                    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid--2002.10.16 wangxin
                    continue
 		end
 		
 		--if @sqty < 0 		    
		--begin
		--    insert into  #noaccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
		--	values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)
		--    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                --    continue
               --end     
               
               if @optionValue <> 0
               begin
               	   if @tmpqty -@sqty >=0 
		   begin
               	       insert into  #noaccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			  values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)
		       fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                       continue
		   end
               end     
               
               --Added by wang xin 2003.04.22
                if (@Qty = 0) and (@Dt2 <> 0)
                begin
                	insert into  #noaccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			  values ('1',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)--2002.10.16 wangxin       
			fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid--2002.10.16 wangxin         
                end      
                     	    			 		     	       						
 	        if @INV_QTY -@Qty >=0
		BEGIN
			insert into  #noaccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			  values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)--2002.10.16 wangxin
			update #inv
			   set qty = qty - @qty
                           WHERE GDGID = @GDGID 
		END
		ELSE
		BEGIN 
			select @DT1 = @DT1*(@QTY-@INV_QTY)/@QTY
			SELECT @DT2 = @DT2*(@QTY-@INV_QTY)/@QTY
			
			insert into  #noaccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			  values ('1',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@QTY-@INV_QTY,@Dt1,@DT2)--2002.10.16 wangxin
           	        update #inv
			   set qty = 0
                           WHERE GDGID = @GDGID 
		END
                fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid--2002.10.16 wangxin
        END	       	
        close C_OSBAL
        deallocate C_OSBAL

	DELETE  #osbal 
            FROM #noaccord 
            WHERE   #osbal.STORE = #noaccord.STORE
		AND #osbal.SETTLENO = #noaccord.SETTLENO
		AND #osbal.DATE =#noaccord.DATE
		AND #osbal.WRH = #noaccord.WRH
		AND #osbal.VDRGID = #noaccord.VDRGID --2002.10.16 wangxin
		AND #osbal.GDGID = #noaccord.GDGID		
		AND #noaccord.FLAG = '0'
	UPDATE #osbal
	    SET #osbal.QTY = #noaccord.QTY,
		#osbal.DT1 = #noaccord.DT1,
		#osbal.DT2 = #noaccord.DT2
            FROM #noaccord
            WHERE   #osbal.STORE = #noaccord.STORE
		AND #osbal.SETTLENO = #noaccord.SETTLENO
		AND #osbal.DATE = #noaccord.DATE
		AND #osbal.WRH = #noaccord.WRH
		AND #osbal.VDRGID = #noaccord.VDRGID--2002.10.16 wangxin
		AND #osbal.GDGID = #noaccord.GDGID
		AND #noaccord.FLAG = '1'
        if @optionValue = 0--不进行库存控制
	begin
       select o.* from #osbal o, goods g(nolock)
       where o.VDRGid = @p_billTo and o.gdgid = g.gid
       order by g.code, o.date
	   return(0)	
	end
	
	SELECT o.* FROM #osbal o, goods g(nolock)
	where o.VDRGid = @p_billTo and o.GdGid <> -1 and o.gdgid = g.gid
    ORDER BY g.code, o.Date 
GO
