SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQSNDDIRALC](
	@NUM VARCHAR(14),
	@CLS VARCHAR(10),
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @GROUPID INT,     @NTYPE SMALLINT,    @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  --exec OPTREADINT 0, '...', 0, @optvalue output
  if not exists(select 1 from diralc where num = @num and cls = @cls and STAT = 6)
  begin
    set @msg = '不能定位已经复核的直配单据'+@num+'-'+@cls
    return 1
  end  
  exec @GROUPID = SeqNextValue 'CHQBASIC'
  set @RHQUUID = '1'
  set @NTYPE = 0
  set @NNOTE = ''
  set @NSTAT = 0
  set @EXTIME = Getdate()
  insert into CQNDIRALC(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME, 
      CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, OCRDATE, 
      PSR, TOTAL, TAX, ALCTOTAL, STAT, SRC, SRCNUM, SNDTIME, 
      NOTE, RECCNT, FILLER, CHECKER, MODNUM, VENDORNUM, FILDATE, 
      FINISHED, PRNTIME, ORDNUM, SRCORDNUM, WRH, CHKDATE, GEN, 
      GENBILL, GENCLS, GENNUM, PRECHECKER, PRECHKDATE, SLR, OUTTAX, 
      RCPFINISHED, PAYMODE, PAYDATE, SRCORDCLS, FROMNUM, FROMCLS)
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, OCRDATE, 
      PSR, TOTAL, TAX, ALCTOTAL, STAT, SRC, SRCNUM, SNDTIME, 
      NOTE, RECCNT, FILLER, CHECKER, MODNUM, VENDORNUM, FILDATE, 
      FINISHED, PRNTIME, ORDNUM, SRCORDNUM, WRH, CHKDATE, GEN, 
      GENBILL, GENCLS, GENNUM, PRECHECKER, PRECHKDATE, SLR, OUTTAX, 
      RCPFINISHED, PAYMODE, PAYDATE, SRCORDCLS, FROMNUM, FROMCLS 
    from DIRALC(nolock)
    where NUM = @NUM AND CLS = @CLS
    
  insert into CQNDIRALCDTL(GROUPID, RHQUUID, NTYPE, NSTAT, NNOTE, EXTIME,
      CLS, NUM, LINE, SETTLENO, GDGID, WRH, CASES, QTY, LOSS, 
      PRICE, TOTAL, TAX, WSPRC, INPRC, RTLPRC, VALIDDATE, BCKQTY, 
      PAYQTY, BCKAMT, PAYAMT, ALCPRC, ALCAMT, BNUM, OUTTAX, RCPQTY, 
      RCPAMT, NOTE, COST, COSTPRC, ORDLINE, snewflag, SUBWRH )
    select @GROUPID, @RHQUUID, @NTYPE, @NSTAT, @NNOTE, @EXTIME, 
      CLS, NUM, LINE, SETTLENO, GDGID, WRH, CASES, QTY, LOSS, 
      PRICE, TOTAL, TAX, WSPRC, INPRC, RTLPRC, VALIDDATE, BCKQTY, 
      PAYQTY, BCKAMT, PAYAMT, ALCPRC, ALCAMT, BNUM, OUTTAX, RCPQTY, 
      RCPAMT, NOTE, COST, COSTPRC, ORDLINE, snewflag, SUBWRH   
    from DIRALCDTL(nolock)
    where NUM = @NUM AND CLS = @CLS  
  declare @vdrgid int
  select @vdrgid = vendor from DIRALC (nolock)
    where NUM = @NUM AND CLS = @CLS 
  if exists(select 1 from vendorh (nolock) where gid = @vdrgid and upay = 1)
    update diralc set finished = 1
    where NUM = @NUM AND CLS = @CLS
end;
GO
