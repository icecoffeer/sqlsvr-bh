SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SVIGen_2](
	@p_Billto int,
	@p_BPayDate  datetime,
	@p_EPayDate  datetime,
	@p_isWrh  smallint,
	@p_isByStore smallint,
	@p_isPsrer smallint,
	@FILLER INT	
	)
as
BEGIN
	declare @OptionValue smallint,
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
		@sTmp	varchar(20),
		@optByDate SMALLINT  
	create table #NoAccord(
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
	create table #OSBAL(
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
		MUNIT	VARCHAR(6),
		RTLPRC  MONEY,
		INPRC	MONEY,
		TAXRATE	MONEY,
		PSR     INT NULL,
		VDRCODE VARCHAR(13) DEFAULT '-' NULL,
		WRHCODE VARCHAR(13) DEFAULT '-' NULL,
		PSRCODE VARCHAR(13) DEFAULT '-' NULL,
		STCODE VARCHAR(13) DEFAULT '-' NULL
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
	
	exec OPTREADINT 470, 'boolByStore', 0, @optByDate output  
        if @optByDate <> 1 and @optByDate <> 0
          SET @optByDate = 0
        
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

      IF @p_billto = 1
        INSERT INTO #tmpgd
        select distinct GDGID
        from OSBAL A,GOODSH B
        where A.GDGID = B.GID and B.SALE = 2 
          and A.VDRGID IN (SELECT GID FROM #VDR)--@p_billto
          and date >= @p_BPayDate and date<= @p_EPayDate
          and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))
      ELSE
        INSERT INTO #tmpgd
        select distinct GDGID
        from OSBAL A,GOODSH B
        where A.GDGID = B.GID and B.SALE = 2 
          --and A.VDRGID IN (SELECT GID FROM #VDR)--@p_billto
          and date >= @p_BPayDate and date<= @p_EPayDate
          and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))
   
	 if @p_isWrh =1      --仓位限制
	begin
	    if @optionValue = 0 and @p_isByStore = 1 --按门店结算 			
	    	if @p_isPsrer = 1 
		    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR  
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where A.GDGID = B.GID and B.SALE = 2 
            	        and A.Wrh  IN (SELECT GID FROM #WRH)  -- SZ 
            	        and A.GDGID = D.GDGID/*2003.10.15*/
            	        and B.PSR IN (SELECT GID FROM #PSR) --SZ
			and Store in (select Gid from #store) 
                        and date >= @p_BPayDate and date<= @p_EPayDate
                        and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))
                    
                else
                    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR	
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where A.GDGID = B.GID and B.SALE = 2 
            	        and A.Wrh IN (SELECT GID FROM #WRH)  -- SZ 
            	        and A.GDGID = D.GDGID/*2003.10.15*/
			and Store in (select Gid from #store) 
                        and date >= @p_BPayDate and date<= @p_EPayDate
                        and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()))
		 --2002.10.29 Wang xin
	    else
	       if @p_isPsrer = 1 
	         IF @optByDate = 1    --指定日期
	            INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where --Date <=@P_EPayDate --2002.10.16 wangxin
			 A.GDGID = B.GID and B.SALE = 2 
			and A.Wrh IN (SELECT GID FROM #WRH)  -- SZ 
			and A.GDGID = D.GDGID/*2003.10.15*/			
			and B.PSR IN (SELECT GID FROM #PSR) --SZ
			and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219
			and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()) )
			 --2002.10.29 Wang xin
	         ELSE  --不指定开始日期
	           INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	      select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where Date <=@P_EPayDate --2002.10.16 wangxin
			and A.GDGID = B.GID and B.SALE = 2 
			and A.Wrh IN (SELECT GID FROM #WRH)  -- SZ 
			and A.GDGID = D.GDGID/*2003.10.15*/			
			and B.PSR IN (SELECT GID FROM #PSR) --SZ
			--and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219
			and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()) )
			 --2002.10.29 Wang xin 
	     else
	       IF @optByDate = 1    --指定日期
	         INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 		
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where --Date <=@P_EPayDate --2002.10.16 wangxin            	       
			 A.GDGID = B.GID and B.SALE = 2 
			and A.Wrh IN (SELECT GID FROM #WRH)  -- SZ  
			and A.GDGID = D.GDGID/*2003.10.15*/
			and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219		
			and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()) )
	        ELSE  --不指定开始日期
	          INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 		
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where Date <=@P_EPayDate --2002.10.16 wangxin            	       
			and A.GDGID = B.GID and B.SALE = 2 
			and A.Wrh IN (SELECT GID FROM #WRH)  -- SZ  
			and A.GDGID = D.GDGID/*2003.10.15*/
			--and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219		
			and not (b.KEEPTYPE & 1 = 1 and b.NCANPAY = 0 and getdate()<=isnull(b.NENDTIME,getdate()) )
			 --2002.10.29 Wang xin
	end
        else
	begin
	    if @optionValue = 0 and @p_isByStore = 1 
	    	if @p_isPsrer = 1
		    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR  	
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where A.GDGID = B.GID and B.SALE = 2 and A.GDGID = D.GDGID/*2003.10.15*/ 
            	        and B.PSR IN (SELECT GID FROM #PSR) --SZ            	        
			and Store in (select Gid from #store) 
                      	and date >= @p_BPayDate and date<= @p_EPayDate
                      	and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin
                 else
                     INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 	 
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where A.GDGID = B.GID and B.SALE = 2 and A.GDGID = D.GDGID/*2003.10.15*/            	       
			and Store in (select Gid from #store) 
                      	and date >= @p_BPayDate and date<= @p_EPayDate
                      	and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin
	    else
	        if @p_isPsrer = 1 
	          IF @optByDate = 1  --指定日期  SZ
		    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 		
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where --Date <=@P_EPayDate  
            	      A.GDGID = B.GID and B.SALE = 2 
            	    and B.PSR IN (SELECT GID FROM #PSR) --SZ
            	    and A.GDGID = D.GDGID/*2003.10.15*/  
            	    and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219          	    
            	    and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin	
            	  ELSE  --不指定开始日期
            	    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 		
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where Date <=@P_EPayDate  
            	    and A.GDGID = B.GID and B.SALE = 2 
            	    and B.PSR IN (SELECT GID FROM #PSR) --SZ
            	    and A.GDGID = D.GDGID/*2003.10.15*/  
            	    --and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219          	    
            	    and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin
                else
                  IF @optByDate = 1  --指定日期  SZ
                    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 		
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where Date <=@P_EPayDate 
            	     and A.GDGID = B.GID and B.SALE = 2 and A.GDGID = D.GDGID/*2003.10.15*/
            	      --and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219
            	    and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin	
            	  ELSE  --不指定开始日期
            	    INSERT INTO #osbal(STORE,SETTLENO,DATE,VDRGID,WRH,GDGID,QTY,DT1,DT2,	
			   CODE,NAMESPEC,MUNIT,RTLPRC,INPRC,TAXRATE, PSR)
   	  	    select A.STORE,A.SETTLENO,A.DATE,A.VDRGID,A.WRH,A.GDGID,A.QTY,A.DT1,A.DT2,
			B.CODE,left(rtrim(B.NAME) +' '+rtrim(B.SPEC),80),B.MUNIT,B.RTLPRC,B.INPRC,B.TAXRATE, B.PSR 		
            	    from OSBAL A,GOODSH B, #tmpgd D/*2003.10.15*/
            	    where --Date <=@P_EPayDate 
            	      A.GDGID = B.GID and B.SALE = 2 and A.GDGID = D.GDGID/*2003.10.15*/
            	      and date >= @p_BPayDate and date<= @p_EPayDate  -- sz 20031219
            	    and (b.KEEPTYPE & 1 <> 1 or b.NCANPAY = 1 or b.NENDTIME < getdate()) --2002.10.29 Wang xin
	end 
	
	--2003.01.22 by wang xin 条件增加： 期号、店号。结束
	select @settleno = no from MONTHSETTLE where BEGINDATE < @p_EPayDate  and @p_EPayDate <= ENDDATE
	select @store = usergid from system	
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
        select STORE,SETTLENO,DATE,WRH,GDGID,ISNULL(QTY,0),isnull(DT1,0),isnull(DT2,0), VDRGID --2002.10.16 wangxin
            from #OSBAL  
	    ORDER BY VDRGID desc, SETTLENO desc ,DATE desc ,STORE desc ,WRH desc ,GDGID DESC --2002.10.16 wangxin
        open C_OSBAL
        fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid --2002.10.16 wangxin	
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
		/*select @sqty = sum(qty)
			from #OSBAL where GDGID = @GDGID and VDRGID = @VDRGID
		select @sqty = isnull(@sqty, 0)		
		
		if @sqty = 0 		    
		begin
		    insert into  #NoAccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)
		    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                    continue
               end */  
               
               if @optionValue = 0
               begin
               	    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                    continue
               end              		               
               
		if @INV_QTY = 0 
		begin
                    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2,@vdrgid
                    continue
 		end      	 	
		
		/*if @sqty < 0 		    
		begin
		    insert into  #NoAccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2)
		    fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
                    continue
               end      
		--若应结数小于等于零则不结算 2002.10.16 wangxin	*/	          	       
		
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
			insert into  #NoAccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			  values ('0',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@Qty,@Dt1,@DT2) --2002.10.16 wangxin
			update #inv
			   set qty = qty - @qty
                           WHERE GDGID = @GDGID 
		END
		ELSE
		BEGIN 
			select @DT1 = @DT1*(@QTY-@INV_QTY)/@QTY
			SELECT @DT2 = @DT2*(@QTY-@INV_QTY)/@QTY
			
			insert into  #NoAccord(FLAG,STORE,SETTLENO,VDRGID,DATE,WRH,GDGID,QTY,DT1,DT2)
			  values ('1',@store,@settleNO,@vdrgid,@date,@Wrh,@GdGid,@QTY-@INV_QTY,@Dt1,@DT2) --2002.10.16 wangxin
           	        update #inv
			   set qty = 0
                           WHERE GDGID = @GDGID 
		END
                fetch next from C_OSBAL into @STORE,@SETTLENO,@DATE,@WRH,@GDGID,@QTY,@DT1,@DT2, @vdrgid
        END	       	
        close C_OSBAL
        deallocate C_OSBAL

	DELETE  #OSBAL 
            FROM #NOACCORD 
            WHERE   #OSBAL.STORE = #NOACCORD.STORE
		AND #OSBAL.SETTLENO = #NOACCORD.SETTLENO
		AND #OSBAL.DATE =#NOACCORD.DATE
		AND #OSBAL.WRH = #NOACCORD.WRH
		AND #osbal.VDRGID = #NOACCORD.VDRGID --2002.10.16 wangxin
		AND #OSBAL.GDGID = #NOACCORD.GDGID
		AND #NOACCORD.FLAG = '0'
	UPDATE #OSBAL
	    SET #OSBAL.QTY = #NOACCORD.QTY,
		#OSBAL.DT1 = #NOACCORD.DT1,
		#OSBAL.DT2 = #NOACCORD.DT2
            FROM #NOACCORD
            WHERE   #OSBAL.STORE = #NOACCORD.STORE
		AND #OSBAL.SETTLENO = #NOACCORD.SETTLENO
		AND #OSBAL.DATE = #NOACCORD.DATE
		AND #OSBAL.WRH = #NOACCORD.WRH
		AND #OSBAL.GDGID = #NOACCORD.GDGID
		AND #osbal.VDRGID = #NOACCORD.VDRGID--2002.10.16 wangxin
		AND #NOACCORD.FLAG = '1'
		
	/*if @p_billto = -1
	    SELECT o.* FROM #OSBAL o, goods g(nolock)
	   	where o.GdGid <> -1 and o.gdgid = g.gid
        ORDER BY o.VDRGID, g.code, o.Date 
    else
        SELECT o.* FROM #OSBAL o, goods g(nolock)
	   	where o.VDRGid = @p_billto and o.GdGid <> -1 and o.gdgid = g.gid
        ORDER BY o.VDRGID, g.code, o.Date */

-------这里开始生成代销结算单----------------------------------------------
  UPDATE #OSBAL SET VDRCODE = ISNULL(B.CODE,'-') FROM #OSBAL A, VENDORH B WHERE A.VDRGID = B.GID
  UPDATE #OSBAL SET WRHCODE = ISNULL(B.CODE,'-') FROM #OSBAL A, WAREHOUSEH B WHERE A.WRH = B.GID
  UPDATE #OSBAL SET PSRCODE = ISNULL(B.CODE,'-') FROM #OSBAL A, EMPLOYEEH B WHERE A.PSR = B.GID
  UPDATE #OSBAL SET STCODE = ISNULL(B.CODE,'-') FROM #OSBAL A, STORE B WHERE A.STORE = B.GID
  --UPDATE #OSBAL SET WRHCODE = '-' WHERE WRHCODE IS NULL
  --UPDATE #OSBAL SET PSRCODE = '-' WHERE PSRCODE IS NULL
  --UPDATE #OSBAL SET STCODE = '-' WHERE STCODE IS NULL
   --SELECT * INTO SZ2 FROM #OSBAL  -- This For Test
  
  DECLARE  @IALL INT
  DECLARE @SplitM VARCHAR(100), @SplitD VARCHAR(100), @SFD VARCHAR(10) 
  DECLARE @SSEL VARCHAR(100), @ODR VARCHAR(100),@SGRP VARCHAR(100) 
  DECLARE @SPPSR INT, @SPWRH INT, @SPSTORE INT
  DECLARE @SB0 VARCHAR(1), @SB1 VARCHAR(1), @SB2 VARCHAR(1), @SB3 VARCHAR(1)
  DECLARE @SETTLE INT
  SELECT @SETTLE = MAX(NO) FROM MONTHSETTLE
  IF (@SETTLE IS NULL)
  BEGIN
    raiserror( 'get current settleno failed!', 16, -1 )
    RETURN 1
  END	
  SELECT @SPPSR = 0, @SPWRH = 0, @SPSTORE = 0
  SELECT @IALL = CAST(OPTIONVALUE AS INT) FROM HDOPTION  WHERE MODULENO = 470 AND OPTIONCAPTION = 'SPlitBill'
  IF @@ROWCOUNT = 0 
    SELECT @IALL = 3
  SELECT @SplitM = RTRIM(OPTIONVALUE) FROM HDOPTION  WHERE MODULENO = 470 AND OPTIONCAPTION = 'SPlitBillOrdM'
  IF @@ROWCOUNT = 0 
    SELECT @SplitM = 'VDRCODE ASC,PSRCODE ASC,WRHCODE ASC'
  SELECT @SplitD = RTRIM(OPTIONVALUE) FROM HDOPTION  WHERE MODULENO = 470 AND OPTIONCAPTION = 'SPlitBillOrdD'
  IF @@ROWCOUNT = 0 
    SELECT @SplitD = ''
  SELECT @SFD = RTRIM(OPTIONVALUE) FROM HDOPTION  WHERE MODULENO = 470 AND OPTIONCAPTION = 'SPlitBillFD'
  IF @@ROWCOUNT = 0 
    SELECT @SFD = '012'
  SELECT  @SSEL = REPLACE(@SplitM,'DESC','')
  SELECT  @SSEL = REPLACE(@SSEL,'ASC','')
  SELECT @SGRP = @SSEL
  SELECT @SB0 = SUBSTRING(@SFD,1,1), @SB1 = SUBSTRING(@SFD,2,1), @SB2 = SUBSTRING(@SFD,3,1), @SB3 = SUBSTRING(@SFD,4,1)
  IF @SB0 = '' OR @SB1 IS NULL
  BEGIN
    raiserror('指定的分单排序条件有误，请重新设置', 16, 1)
    return(1)	
  END
  IF @SB1 = '' OR @SB1 IS NULL SELECT @SSEL = @SSEL + ', ''1'' ' 
  IF @SB2 = '' OR @SB2 IS NULL SELECT @SSEL = @SSEL + ', ''2'' '
  IF @SB3 = '' OR @SB3 IS NULL SELECT @SSEL = @SSEL + ', ''3'' '
  IF @SB0 = '3' OR @SB1 = '3' OR @SB2 = '3' OR @SB3 = '3'  SET @SPSTORE = 1 ELSE SET @SPSTORE = 0
  IF @SB0 = '2' OR @SB1 = '2' OR @SB2 = '2' OR @SB3 = '2'  SET @SPWRH = 1 ELSE SET @SPWRH = 0
  IF @SB0 = '1' OR @SB1 = '1' OR @SB2 = '1' OR @SB3 = '1'  SET @SPPSR = 1 ELSE SET @SPPSR = 0
  
  DECLARE @DPSR INT, @DWRH INT, @DSTORE INT
  IF @p_isPsrer = 0
    SELECT @DPSR = 1
  ELSE
  BEGIN
    SELECT @DPSR = COUNT(*) FROM #PSR
    IF @DPSR > 1 
      SELECT @DPSR = 1
    ELSE
     SELECT @DPSR = GID FROM #PSR 
  END
  IF @p_isWrh = 0
    SELECT @DWRH = 1
  ELSE
  BEGIN
    SELECT @DWRH = COUNT(*) FROM #WRH
    IF @DWRH > 1 
      SELECT @DWRH = 1
    ELSE
     SELECT @DWRH = GID FROM #WRH
  END
  IF @p_isByStore = 0
    SELECT @DSTORE = 1
  ELSE
  BEGIN
    SELECT @DSTORE = COUNT(*) FROM #STORE
    IF @DSTORE > 1 
      SELECT @DSTORE= 1
    ELSE
     SELECT @DSTORE = GID FROM #STORE
  END 
  
  DECLARE @SCCD0 VARCHAR(13),@SCCD1 VARCHAR(13),@SCCD2 VARCHAR(13),@SCCD3 VARCHAR(13)
  DECLARE @VCMD1 VARCHAR(1500), @VCFD VARCHAR(80)
  
  DECLARE @XGDGID INT, @XSETTLENO INT, @XDATE DATETIME, @XDT1 MONEY, @XDT2 MONEY, @XQTY MONEY
  DECLARE @XCODE VARCHAR(13), @XNAMESPEC VARCHAR(80), @XMUNIT VARCHAR(6), @XRTLPRC MONEY, @XINPRC MONEY
  DECLARE @XTAXRATE MONEY, @XSTORE INT,@XVDRGID INT, @XWRH INT, @XPSR INT
  DECLARE  @PXSETTLENO INT, @PXDATE DATETIME, @PXDT1 MONEY, @PXDT2 MONEY, @PXQTY MONEY
  DECLARE @PXCODE VARCHAR(13), @PXNAMESPEC VARCHAR(80), @PXMUNIT VARCHAR(6), @PXRTLPRC MONEY, @PXINPRC MONEY
  DECLARE @PXTAXRATE MONEY, @PXSTORE INT, @PXWRH INT, @PXPSR INT, @PXVDRGID INT
  DECLARE @NUM VARCHAR(13), @LINE1 INT, @LINE2 INT  --DTLDTL'S LINE
  DECLARE @LSTGDGID INT
  DECLARE @LSTTAXRATE MONEY ,@NOTE VARCHAR(255)
  DECLARE @VCMD VARCHAR(2000),@RTN INT
  DECLARE @SXDT2 MONEY, @SXTAX MONEY,@SXAMT MONEY, @SXSAMT MONEY, @SXQTY MONEY -- SUMMARY INFO
  SELECT @VCMD = 'DECLARE SVI2_1 CURSOR for '
               + ' SELECT ' + @SSEL + '  FROM #OSBAL WHERE '
               + ' GdGid <> -1 GROUP BY ' + @SGRP + '  ORDER BY ' + @SplitM
  EXEC(@VCMD)
  OPEN SVI2_1
  FETCH NEXT FROM SVI2_1 INTO @SCCD0,@SCCD1,@SCCD2,@SCCD3
  WHILE @@fetch_status = 0
  BEGIN
    EXEC SVIGETNEXTNUM @NUM OUTPUT  --取单号
    SELECT @LINE1 = 0, @LINE2 = 0, @SXAMT = 0, @SXQTY = 0, @SXDT2 = 0
    SELECT @VCMD1 = 'DECLARE SVI2_2 CURSOR for '
               + ' SELECT GDGID, SETTLENO,DATE,QTY,DT1,DT2, CODE, NAMESPEC, MUNIT, RTLPRC, '
               + ' INPRC, TAXRATE, STORE, VDRGID, WRH, PSR  FROM #OSBAL WHERE GdGid <> -1 '
    EXEC SVIGETFIELD @SB0, @SCCD0, @VCFD OUTPUT
    SET @VCMD1 = @VCMD1 + ' ' + @VCFD 
    EXEC SVIGETFIELD @SB1, @SCCD1, @VCFD OUTPUT
    SET @VCMD1 = @VCMD1 + ' ' + @VCFD   
    EXEC SVIGETFIELD @SB2, @SCCD2, @VCFD OUTPUT
    SET @VCMD1 = @VCMD1 + ' ' + @VCFD
    EXEC SVIGETFIELD @SB3, @SCCD3, @VCFD OUTPUT
    SET @VCMD1 = @VCMD1 + ' ' + @VCFD
    SET @VCMD1 = @VCMD1 + ' ORDER BY GDGID '
    IF @SplitD <> '' 
      SELECT @VCMD1 = @VCMD1 + ', ' + @SplitD
    --------------------------------------------------------------------
    EXEC(@VCMD1)
    OPEN SVI2_2
    FETCH NEXT FROM SVI2_2 INTO @XGDGID,@XSETTLENO,@XDATE,@XQTY,@XDT1,@XDT2, @XCODE, @XNAMESPEC, @XMUNIT, @XRTLPRC, 
                @XINPRC, @XTAXRATE, @XSTORE, @XVDRGID, @XWRH, @XPSR
    SELECT @LSTGDGID = @XGDGID, @LSTTAXRATE = @XTAXRATE , @PXSETTLENO = @XSETTLENO
    SELECT @PXDATE = @XDATE, @PXCODE = @XCODE,@PXNAMESPEC = @XNAMESPEC, @PXMUNIT = @XMUNIT , @PXTAXRATE = @XTAXRATE, @PXRTLPRC = @XRTLPRC, @PXINPRC = @XINPRC
    WHILE @@fetch_status = 0
    BEGIN
      SELECT @PXVDRGID = @XVDRGID 	
      IF @LSTGDGID <> @XGDGID  -- DTL SPLIT, SAVE DTL INFO
      BEGIN
      	EXEC SVIGETTAX @SXDT2, @LSTTAXRATE, @SXTAX OUTPUT
      	SELECT @SXAMT = @SXAMT + @SXDT2
        SELECT @SXSAMT = @SXAMT
        INSERT INTO SVIDTL (NUM, LINE, SETTLENO, GDGID, QTY, TOTAL, STOTAL, BPAYDATE, EPAYDATE, INPRC, RTLPRC, TAX, CLS, FROMTOTAL) VALUES
          (@NUM, @LINE1, @PXSETTLENO, @LSTGDGID, @SXQTY, @SXDT2, @SXDT2, @p_BPayDate, @p_EPayDate, @PXINPRC, @PXRTLPRC, @SXTAX,'代销',@SXDT2)
        SELECT @SXQTY = 0, @LINE2 = 1
        SET @LINE1 = @LINE1 + 1
        SELECT @LSTGDGID = @XGDGID, @LSTTAXRATE = @XTAXRATE, @PXSETTLENO = @XSETTLENO
        SELECT @PXDATE = @XDATE, @PXCODE = @XCODE,@PXNAMESPEC = @XNAMESPEC, @PXMUNIT = @XMUNIT , @PXTAXRATE = @XTAXRATE, @PXRTLPRC = @XRTLPRC, @PXINPRC = @XINPRC
        SELECT @SXQTY = 0, @SXDT2 = 0
      END  -- DTL GID <>
      ----  SAVE DTLDTL INFO
      
      SELECT  @SXDT2 = @SXDT2 + @XDT2, @SXQTY = @SXQTY + @XQTY	
      INSERT INTO SVIDTLDTL (NUM, LINE, ITEM, STORE, SETTLENO, DATE, VDRGID, WRH, GDGID, QTY, DT1, DT2, DT3, CLS, ISPAY) VALUES
        (@NUM, @LINE1, @LINE2, @XSTORE, @XSETTLENO, @XDATE, @XVDRGID, @XWRH, @XGDGID, @XQTY, @XDT1, @XDT2, @XDT2, '代销', 0)
      SET @LINE2 = @LINE2 + 1;
      --END  -- DTLDTL INFO
      IF @SPPSR = 0
      SELECT @PXPSR = @DPSR
    ELSE
      SELECT @PXPSR = @XPSR
    IF @SPWRH = 0
      SELECT @PXWRH = @DWRH
    ELSE
      SELECT @PXWRH = @XWRH
    IF @SPSTORE = 0
      SELECT @PXSTORE = @DSTORE
    ELSE
      SELECT @PXSTORE = @XSTORE
    /*IF @PXPSR IS NULL
      SET @PXPSR = 1
    IF @PXWRH IS NULL
      SET @PXWRH = 1
    IF @PXSTORE IS NULL
      SET @PXSTORE = 1 */
      FETCH NEXT FROM SVI2_2 INTO @XGDGID,@XSETTLENO,@XDATE,@XQTY,@XDT1,@XDT2, @XCODE, @XNAMESPEC, @XMUNIT, @XRTLPRC, 
                @XINPRC, @XTAXRATE, @XSTORE, @XVDRGID, @XWRH, @XPSR
      IF (@@fetch_status <> 0)  -- SAVE LAST DTL
      BEGIN
      	EXEC SVIGETTAX @SXDT2, @LSTTAXRATE, @SXTAX OUTPUT
      	SELECT @SXAMT = @SXAMT + @SXDT2
        SELECT @SXSAMT = @SXAMT
        INSERT INTO SVIDTL (NUM, LINE, SETTLENO, GDGID, QTY, TOTAL, STOTAL, BPAYDATE, EPAYDATE, INPRC, RTLPRC, TAX, CLS, FROMTOTAL) VALUES
          (@NUM, @LINE1, @PXSETTLENO, @LSTGDGID, @SXQTY, @SXDT2, @SXDT2, @p_BPayDate, @p_EPayDate, @PXINPRC, @PXRTLPRC, @SXTAX,'代销',@SXDT2)
      END 
    END  -- END FETCH SECOND
    CLOSE SVI2_2
    DEALLOCATE SVI2_2
    ----SAVE MST INFO

    EXEC @RTN = SVIFILLSTOREINFO @NUM, @PXSTORE, @SPSTORE, @p_isByStore, @NOTE OUTPUT
    SELECT @NOTE = @NOTE + CONVERT( VARCHAR(10), @p_BPayDate, 126) + '到' + CONVERT( VARCHAR(10), @p_EPayDate, 126) + ' 代销帐款'
    INSERT INTO SVI (NUM, SETTLENO, FILDATE, CHECKER, WRH, BILLTO, BPAYDATE, EPAYDATE, AMT, SAMT, STAT, CLS, PSR, PAYTOTAL, FILLER, NOTE) VALUES
        (@NUM, @SETTLE, GETDATE(), 1, @PXWRH, @PXVDRGID, @p_BPayDate, @p_EPayDate, @SXAMT, @SXSAMT, 0, '代销', @PXPSR, 0, @FILLER, @NOTE)
    EXEC @RTN = SVIFILLTMPSVI @NUM, @SPWRH, @p_isWrh, @PXWRH, @SPPSR, @p_isPsrer, @PXPSR, @SPSTORE, @p_isByStore, @PXSTORE, @XVDRGID
    FETCH NEXT FROM SVI2_1 INTO @SCCD0,@SCCD1,@SCCD2,@SCCD3
  END  -- END FETCH FIRST
  CLOSE SVI2_1
  DEALLOCATE SVI2_1
  RETURN 0
END
GO
