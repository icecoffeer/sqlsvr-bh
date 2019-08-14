SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQRCVGOODSAPP](
	@piGroupID INT,
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @NTYPE SMALLINT,  @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  declare @OPTVALUE int,		@SETTLENO int,			@USERGID int,
          @OPER varchar(30),@NUM varchar(14),
          @FrcChk int,      @STOREGID int,      @ExistStat int
  set @optvalue = 0
  set @msg = ''  
  exec OPTREADINT 0, 'USECHQ', 0, @OPTVALUE output
  if @OPTVALUE <> 1 
  begin
    set @msg = '使用选项没有打开'
    return 1  
  end
  select @settleno = Max(no) from monthsettle
  select @usergid = usergid from system(nolock)
  select @FrcChk = STAT, @NUM = NUM from cqnGoodsApp(nolock) where GroupID = @piGroupID and NTYPE = 1
  select @OPER = rtrim(name) + '[' + rtrim(code) + ']' from employee(nolock) where gid = @opergid
  select @ExistStat = stat from GoodsApp(nolock) where num = @num
  --获得单号
  --exec GENNEXTBILLNUMEX '', 'GOODSAPP', @newnum output
  if @ExistStat = 411
  begin
    set @msg = '单据在分部被作废，不能接收。'
    update CQNGoodsApp set NNOTE = @msg
    where GroupID = @piGroupID and NTYPE = 1
    return -1  
  end
  if @ExistStat = 400
  begin
    set @msg = '单据已经被审核，不能接收。'
    update CQNGoodsApp set NNOTE = @msg
    where GroupID = @piGroupID and NTYPE = 1
    return -1  
  end
  if @ExistStat = 401
  begin
    delete from GoodsApp where num = @num
    delete from GoodsAppDtl where num = @num
    delete from GoodsAppField where num = @num
    delete from GoodsAppLac where num = @num
  end
  if @ExistStat is null or @ExistStat = 401
  begin
    insert into GoodsApp( 
      	NUM ,STAT ,RATIFIER ,SRC ,PSR ,FILDATE ,FILLER ,CHECKER ,CHKDATE ,
      	RATOPER ,RATDATE ,DEADDATE ,LSTUPDTIME ,PRNTIME ,SNDTIME ,
      	SETTLENO ,NOTE ,GOODSCLS ,APPMODE ,RECCNT ,MODNUM, BOCLS)
      select 
        NUM ,401 ,@USERGID ,@USERGID ,1 ,FILDATE ,FILLER ,CHECKER ,CHKDATE ,
      	RATOPER ,RATDATE ,DEADDATE ,LSTUPDTIME ,PRNTIME ,SNDTIME ,
      	@SETTLENO ,'[大总部生成]' + NOTE ,GOODSCLS ,APPMODE ,RECCNT ,MODNUM, '大总部生成'
      from CQNGoodsApp m(nolock)
      where GroupID = @piGroupID and NTYPE = 1
      
    insert Into GoodsAppDtl(
      	NUM, LINE, FLAG, RATFLAG, NOTE, CODE, NAME, SPEC, SORT, 
      	RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, 
      	WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, 
      	MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC, /*UBILLTO,*/ AUTOORD, ORIGIN, 
      	GRADE , MBRPRC , SALETAX , PSR , F1 , F2, F3, ALC, CODE2, MKTINPRC, 
      	MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NEndTime, 
      	NCanPay, SSStart, SSEnd, Season, HQControl, ORDCYCLE, ALCCTR, ISDISP, 
      	GID, BILLTO)
      select NUM, LINE, FLAG, RATFLAG, NOTE, '', NAME, SPEC, SORT, --代码接收成空
      	RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, 
      	WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, 
      	MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC, /*UBILLTO,*/ AUTOORD, ORIGIN, 
      	GRADE , MBRPRC , SALETAX , PSR , F1 , F2, F3, ALC, CODE2, MKTINPRC, 
      	MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NEndTime, 
      	NCanPay, SSStart, SSEnd, Season, HQControl, ORDCYCLE, ALCCTR, ISDISP, 
      	GID, BILLTO
      from CQNGoodsAppDTL where GroupID = @piGroupID and NTYPE = 1
      
    insert Into GoodsAppField(NUM ,LINE ,FIELDNAME)
      select NUM ,LINE ,FIELDNAME
      from CQNGoodsAppField m(nolock) where GroupID = @piGroupID and NTYPE = 1
    
    --插入生效门店
    insert into GoodsAppLac(num, storegid)
      select @num, @usergid
      
    if @FrcChk = 1
    begin
      PRINT ''
    	--审核
    	--exec GoodsAppChk @Cls, @num
    	/*
    	--发送回大总部
    	declare c_store for
    	  select storegid from GoodsAppLacDtl(nolock) 
    	    where cls = @cls and num = @num and storegid <> @usergid
    	open c_store
    	fetch next from c_store into @storegid
    	while @@fetch_status = 0 
    	begin
    		exec @ret = GoodsAppSND @Cls, @num, @storegid,@FrcChk
    		fetch next from c_store into @storegid
    	end;
    	close c_store
    	deallocate c_store
    	if @ret <> 0
    	  return 0
    	*/
    end
  end
  delete from CQNGoodsApp where GROUPID = @piGroupID and NTYPE = 1
  delete from CQNGoodsAppDtl where GROUPID = @piGroupID and NTYPE = 1
  delete from CQNGoodsAppField where GROUPID = @piGroupID and NTYPE = 1
  return 0
end;
GO
