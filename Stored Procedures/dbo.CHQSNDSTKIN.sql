SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQSNDSTKIN](
	@NUM VARCHAR(14),
	@CLS VARCHAR(10),
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @GROUPID INT,     @NTYPE SMALLINT,    @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  if not exists(select 1 from stkin where num = @num and cls = @cls and STAT = 6)
  begin
    set @msg = '不能定位已经复核的进货单'+@num+'-'+@cls
    return 1
  end
  --exec OPTREADINT 0, '...', 0, @optvalue output
  exec @GROUPID = SeqNextValue 'CHQBASIC'
  set @RHQUUID = '1'
  set @NTYPE = 0
  set @NNOTE = ''
  set @NSTAT = 0
  set @EXTIME = Getdate()
  insert into CQNSTKIN(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME, 
      CLS, NUM, ORDNUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE, 
      TOTAL, TAX, NOTE, FILDATE, PAYDATE, FINISHED, FILLER, CHECKER, 
      STAT, MODNUM, PSR, RECCNT, SRC, SRCNUM, SNDTIME, PRNTIME, WRH, 
      CHKDATE, VERIFIER, GEN, GENBILL, GENCLS, GENNUM, PRECHECKER, 
      PRECHKDATE)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CLS, NUM, ORDNUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE, 
      TOTAL, TAX, NOTE, FILDATE, PAYDATE, FINISHED, FILLER, CHECKER, 
      STAT, MODNUM, PSR, RECCNT, SRC, SRCNUM, SNDTIME, PRNTIME, WRH, 
      CHKDATE, VERIFIER, GEN, GENBILL, GENCLS, GENNUM, PRECHECKER, 
      PRECHKDATE
    from STKIN(nolock)
    where NUM = @NUM AND CLS = @CLS
    
  insert into CQNSTKINDTL(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME,
      CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, LOSS, PRICE, 
      TOTAL, TAX, VALIDDATE, WRH, BCKQTY, PAYQTY, INPRC, RTLPRC, 
      PAYAMT, BCKAMT, BNUM, SUBWRH, NOTE, ORDLINE, SNEWFLAG, 
      CHECKOUTFLAG)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, LOSS, PRICE, 
      TOTAL, TAX, VALIDDATE, WRH, BCKQTY, PAYQTY, INPRC, RTLPRC, 
      PAYAMT, BCKAMT, BNUM, SUBWRH, NOTE, ORDLINE, SNEWFLAG, 
      CHECKOUTFLAG   
    from STKINDTL(nolock)
    where NUM = @NUM AND CLS = @CLS    
  declare @vdrgid int
  select @vdrgid = vendor from stkin (nolock)
    where NUM = @NUM AND CLS = @CLS 
  if exists(select 1 from vendorh (nolock) where gid = @vdrgid and upay = 1)
    update stkin set finished = 1
    where NUM = @NUM AND CLS = @CLS 
end;
GO
