SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQSNDGoodsApp](
	@NUM VARCHAR(14),
	@CLS VARCHAR(10),
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @GROUPID INT,     @NTYPE SMALLINT,    @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  declare @vGID INT,        @vMsg varchar(255)
  if not exists(select 1 from GoodsApp where num = @num and STAT = 400)
  begin
    set @msg = '不能定位已经批准的单据'+@num
    return 1
  end
  --exec OPTREADINT 0, '...', 0, @optvalue output
  exec @GROUPID = SeqNextValue 'CHQBASIC'
  set @RHQUUID = '1'
  set @NTYPE = 0
  set @NNOTE = ''
  set @NSTAT = 0
  set @EXTIME = Getdate()
  insert into CQNGoodsApp(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME,
        NUM ,STAT ,RATIFIER ,SRC ,PSR ,FILDATE ,FILLER ,CHECKER ,CHKDATE ,
      	RATOPER ,RATDATE ,DEADDATE ,LSTUPDTIME ,PRNTIME ,SNDTIME ,
      	SETTLENO ,NOTE ,GOODSCLS ,APPMODE ,RECCNT ,MODNUM)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
        NUM ,STAT ,RATIFIER ,SRC ,PSR ,FILDATE ,FILLER ,CHECKER ,CHKDATE ,
      	RATOPER ,RATDATE ,DEADDATE ,LSTUPDTIME ,PRNTIME ,SNDTIME ,
      	SETTLENO ,NOTE ,GOODSCLS ,APPMODE ,RECCNT ,MODNUM
    from GOODSAPP(nolock)
    where NUM = @NUM 
    
  insert into CQNGoodsAppDTL(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME,
        NUM, LINE, FLAG, RATFLAG, NOTE, CODE, NAME, SPEC, SORT, 
      	RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, 
      	WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, 
      	MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC, /*UBILLTO,*/ AUTOORD, ORIGIN, 
      	GRADE , MBRPRC , SALETAX , PSR , F1 , F2, F3, ALC, CODE2, MKTINPRC, 
      	MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NEndTime, 
      	NCanPay, SSStart, SSEnd, Season, HQControl, ORDCYCLE, ALCCTR, ISDISP, 
      	GID, BILLTO, UBILLTO, GDUUID)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
        NUM, LINE, FLAG, RATFLAG, NOTE, CODE, NAME, SPEC, SORT,   
      	RTLPRC, INPRC, TAXRATE, PROMOTE, PRCTYPE, SALE, LSTINPRC, LWTRTLPRC, 
      	WHSPRC, WRH, ACNT, PAYTODTL, PAYRATE, MUNIT, GFT, QPC, TM, MANUFACTOR, 
      	MCODE, GPR, VALIDPERIOD, MEMO, CHKVD, DXPRC, /*UBILLTO,*/ AUTOORD, ORIGIN, 
      	GRADE , MBRPRC , SALETAX , PSR , F1 , F2, F3, ALC, CODE2, MKTINPRC, 
      	MKTRTLPRC, CNTINPRC, ALCQTY, BRAND, BQTYPRC, KEEPTYPE, NEndTime, 
      	NCanPay, SSStart, SSEnd, Season, HQControl, ORDCYCLE, ALCCTR, ISDISP, 
      	GID, BILLTO, '', ''
    from GOODSAPPDTL(nolock)
    where NUM = @NUM  
    
  insert Into CQNGoodsAppField(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME,
        NUM ,LINE ,FIELDNAME)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
        NUM ,LINE ,FIELDNAME
    from GoodsAppField m(nolock) where NUM = @NUM 
  
  --发送批准后生成的商品
  set @vMsg = ''
  declare c_c cursor READ_ONLY for 
    select GID from GoodsAppDtl (nolock) where num = @num and GID is not null and GID <> 0
  open c_c
  fetch next from c_c into @vGID
  while (@@fetch_status = 0)
  begin
    exec CHQSNDGOODS @vGid, @OPERGID, @vMsg output
    if @vMsg <> '' 
    begin
      set @Msg = '发送商品:[' + @vGid + ']时发生错误 - ' + @vMsg
      close c_c
      deallocate c_c
    end
    fetch next from c_c into @vGID
  end
  close c_c
  deallocate c_c
  return 0
end;
GO
